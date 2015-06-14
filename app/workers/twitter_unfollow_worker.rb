class TwitterUnfollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(30) }

  def perform
    unless ENV['WORKERS_DRY_RUN'].blank?
      puts "TwitterUnfollowWorker run but returning due to WORKERS_DRY_RUN env variable"
      return
    end

    User.wants_twitter_unfollow.find_in_batches do |group|
      group.each do |user|
        begin
          follow_prefs = user.twitter_follow_preference
          unfollow_days = follow_prefs.unfollow_after
          users_to_unfollow = user.twitter_follows.where('followed_at <= ? AND UNFOLLOWED IS NOT TRUE', unfollow_days.to_i.days.ago)
          
          client = user.credential.twitter_client rescue nil

          next if client.nil? || users_to_unfollow.empty?
          next unless user.can_twitter_unfollow?

          users_to_unfollow.each do |followed_user|
            begin
              username = followed_user.username
              
              client.unmute(username)
              unfollowed = client.unfollow(username)
              followed_user.update_attributes({ unfollowed: true, unfollowed_at: DateTime.now }) if unfollowed.present?

              # puts "Unfollow (#{user.twitter_username}) - Unfollowing #{followed_user.username}"
            rescue Twitter::Error::Forbidden => e
              # puts "Unfollow (#{user.twitter_username}) - Twitter::Error::Forbidden #{e}"
            rescue Twitter::Error::NotFound => e
              Airbrake.notify(e)
              # followed_user.update_attributes({ unfollowed: true, unfollowed_at: DateTime.now })
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
end