class TwitterFollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 10, 20, 30, 40, 50) }

  def perform
    User.wants_twitter_follow.find_in_batches do |group|
      group.each do |user|
        begin
          follow_prefs = user.twitter_follow_preference
          hashtags = follow_prefs.hashtags.split(',')

          client = user.credential.twitter_client rescue nil

          next if client.nil?
          next if follow_prefs.rate_limited? || hashtags.empty?
          
          usernames = []

          hashtags.each do |hashtag|
            tweets = client.search("##{hashtag}").collect

            tweets.each do |tweet|
              username = tweet.user.screen_name.to_s

              next if usernames.include?(username)
              usernames << username

              # dont follow people we previously have
              entry = TwitterFollow.where(user: user, username: username)
              puts "Follow Worker: #{user.name} - Previously followed #{entry.first.username}" if entry.present?
              next if entry.present?

              client.mute(username) # don't show their tweets in the feed
              client.follow(username)

              TwitterFollow.follow(user, username)
              puts "Follow Worker: #{user.name} - Following #{username}"
            end
          end
          
        rescue Twitter::Error::TooManyRequests => e
          sleep_time = (e.rate_limit.reset_in + 1.minute)/60 rescue 16
          follow_prefs.rate_limit_until = DateTime.now + sleep_time.minutes
          follow_prefs.save
          puts "Sleeping until: #{follow_prefs.rate_limit_until}: #{user.name}"
        rescue Twitter::Error::Forbidden => e
          puts "Twitter::Error::Forbidden: #{user.name}"
        rescue => e
          puts "Follow Worker: ERROR:: \n #{e}"
          Airbrake.notify(e)
        end
      end
    end
  end
end