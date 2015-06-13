class TwitterFollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 5, 10, 15, 20, 25,  30, 35,  40, 45, 50, 55) } if Rails.env.production?

  def perform
    User.wants_twitter_follow.find_in_batches do |group|
      group.each do |user|
        begin
          follow_prefs = user.twitter_follow_preference
          hashtags = follow_prefs.hashtags.gsub('#','').gsub(' ','').split(',').shuffle

          client = user.credential.twitter_client rescue nil

          next if !user.twitter_check? || user.rate_limited? || !user.can_twitter_follow?

          # TODO this doesn't work
          # keep count of followers daily
          # begin
          #   if DateTime.now.in_time_zone.hour = 23 # 11pm pst
          #     Follower.compose(user) if Follower.can_compose_for?(user)
          #   end
          # rescue => e
          #   Airbrake.notify(e)
          # end

          usernames = []

          hashtags.each do |hashtag|
            tweets = client.search("##{hashtag}").collect.take(rand(20..300))

            tweets.each do |tweet|
              username = tweet.user.screen_name.to_s
              twitter_user_id = tweet.user.id

              next if usernames.include?(username)
              usernames << username

              # dont follow people we previously have
              entry = TwitterFollow.where(user: user, username: username)
              next if entry.present?

              muted = client.mute(username) # don't show their tweets in our feed
              followed = client.follow(username)

              TwitterFollow.follow(user, username, hashtag, twitter_user_id) if followed
              # puts "Follow (#{user.twitter_username}) - #{username} | Hashtag: #{hashtag}" if followed
            end
          end
        rescue Twitter::Error::TooManyRequests => e
          # rate limited - set rate_limit_until timestamp
          sleep_time = (e.rate_limit.reset_in + 1.minute)/60 rescue 16
          follow_prefs.rate_limit_until = DateTime.now + sleep_time.minutes
          follow_prefs.save
          # puts "Sleeping until: #{follow_prefs.rate_limit_until}: (#{user.twitter_username})"
        rescue Twitter::Error::Forbidden => e
          # Airbrake.notify(e)
          puts e
        rescue Twitter::Error::Unauthorized => e
          follow_prefs.update_attributes(mass_follow: false, mass_unfollow: false)
          puts e
          Airbrake.notify(e)
        rescue => e
          Airbrake.notify(e)
        end
      end
    end
  end
end