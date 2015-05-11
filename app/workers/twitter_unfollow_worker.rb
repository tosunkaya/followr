class TwitterUnfollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 30) } if Rails.env.production?

  def perform
    User.wants_twitter_unfollow.find_in_batches do |group|
      group.each do |user|
        begin
          follow_prefs = user.twitter_follow_preference
          unfollow_days = follow_prefs.unfollow_after
          users_to_unfollow = user.twitter_follow.where('followed_at <= ? AND UNFOLLOWED IS NOT TRUE', unfollow_days.to_i.days.ago)
          
          client = user.credential.twitter_client rescue nil

          next if client.nil?
          next if users_to_unfollow.empty?

          users_to_unfollow.each do |followed_user|
            begin
              username = followed_user.username
              
              client.unmute(username)
              client.unfollow(username)
              followed_user.update_attributes({ unfollowed: true, unfollowed_at: DateTime.now })

              puts "Unfollow (#{user.name}) - Unfollowing #{followed_user.username}"
            rescue Twitter::Error::Forbidden => e
              puts "Unfollow (#{user.name}) - Twitter::Error::Forbidden #{e}"
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
end