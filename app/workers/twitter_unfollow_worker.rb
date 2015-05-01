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

          next if unfollow_days < 1

          users_to_unfollow = user.twitter_follow.where('followed_at >= ? AND unfollowed IS FALSE', unfollow_days.days.ago)

          next if users_to_unfollow.empty?

          users_to_unfollow.each do |followed_user|
            begin
              client.unfollow(followed_user.twitter_id)
            rescue Twitter::Error::NotFound => e
            rescue => e
              Raygun.track_exception(e)
            ensure
              followed_user.update_attributes(unfollowed: true)
              followed_user.update_attributes(unfollowed_at: DateTime.now)
            end
          end
        rescue => e
          Raygun.track_exception(e)
        end
      end
    end
  end
end