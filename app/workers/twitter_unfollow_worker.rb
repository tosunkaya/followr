class TwitterUnfollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 5, 10, 15, 20, 25,  30, 35,  40, 45, 50, 55) }

  def perform
    unless ENV['WORKERS_DRY_RUN'].blank?
      puts "TwitterUnfollowWorker run but returning due to WORKERS_DRY_RUN env variable"
      return
    end

    User.wants_twitter_unfollow.find_each do |user|
      begin
        client = user.credential.twitter_client rescue nil
        next if client.nil? || !user.can_twitter_unfollow?

        follow_prefs = user.account
        unfollow_days = follow_prefs.unfollow_after
        users_to_unfollow = user.follows.where('followed_at <= ? AND UNFOLLOWED IS NOT TRUE', unfollow_days.to_i.days.ago).limit(15)

        users_to_unfollow.each do |followed_user|
          begin
            username = followed_user.username

            if client.unfollow(username)
              followed_user.update_attributes({ unfollowed: true, unfollowed_at: DateTime.now })
              client.unmute(username)
              client.friendship_update(username, { :wants_retweets => true })
            end
          rescue Twitter::Error::Forbidden => e
          rescue Twitter::Error::NotFound => e
            followed_user.update_attributes({ unfollowed: true, unfollowed_at: DateTime.now })
          rescue => e
            Airbrake.notify(e)
          end
        end
      rescue => e
        Airbrake.notify(e)
      end
    end
  end
end
