class TwitterFollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55) }

  def perform
    User.wants_twitter_follow.find_in_batches do |group|
      group.each do |user|
        begin
          follow_prefs = user.twitter_follow_preference
          hashtags = follow_prefs.hashtags.split(',')

          credentials = user.credential
          next unless credentials.twitter_valid?

          client = user.credential.twitter_client rescue nil

          next if client.nil?
          next if follow_prefs.rate_limited? || hashtags.blank?
          
          
          twitter_users_passed = []

          client.search("##{hashtags.sample}", lang: 'en').take(1000).collect.each do |tweet|
            username = tweet.user.screen_name.to_s

            next if twitter_users_passed.include?(username)
            twitter_users_passed << username

            # dont follow people we previously have
            entry = TwitterFollow.where(user: user, username: username)
            puts "Follow Worker: #{user.email} - Previously followed #{entry.username}" if entry.present?
            next if entry.present?

            client.mute(username) # don't show their tweets in the feed
            client.follow(username)

            TwitterFollow.follow(user, username)
            puts "Follow Worker: #{user.email}: #{username}"
          end
          
        rescue Twitter::Error::TooManyRequests => e
          sleep_time = (e.rate_limit.reset_in + 1.minute)/60 rescue 16
          follow_prefs.rate_limit_until = DateTime.now + sleep_time.minutes
          follow_prefs.save
          puts "Sleeping until: #{follow_prefs.rate_limit_until}: #{user.email}"
        rescue Twitter::Error::Forbidden => e
          puts "Twitter::Error::Forbidden: #{user.email}"
        rescue => e
          puts "Follow Worker: ERROR:: \n #{e}"
          Airbrake.notify(e)
        end
      end
    end
  end
end