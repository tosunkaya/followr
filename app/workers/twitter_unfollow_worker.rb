class TwitterUnfollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  recurrence { hourly.minute_of_hour(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55) }

  def perform
    User.wants_twitter_follow.find_in_batches do |group|
      group.each do |user|
        begin
          follow_prefs = user.twitter_follow_preference
          unfollow_days = follow_prefs.unfollow_after
          users_to_unfollow = user.twitter_follow.where('followed_at <= ? AND UNFOLLOWED IS NOT TRUE', unfollow_days.to_i.days.ago)
          
          client = user.credential.twitter_client

          next if client.nil?
          next if unfollow_days < 1
          next if users_to_unfollow.empty?

          users_to_unfollow.each do |followed_user|
            begin
              puts "Unfollow Worker: #{user.email}: #{followed_user.username}"
              
              client.unfollow(followed_user.username)
              client.unmute(username)

              followed_user.update_attributes({unfollowed: true, unfollowed_at:DateTime.now})
            rescue Twitter::Error::NotFound => e
              followed_user.update_attributes({unfollowed: true, unfollowed_at:DateTime.now})
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