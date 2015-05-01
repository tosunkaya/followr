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

          next if follow_prefs.rate_limited? || hashtags.blank?

          client = Credential.find(user).twitter_client
          
          twitter_users_passed = []

          client.search("#{hashtags.sample} -rt", lang: 'en').take(1000).collect.each do |tweet|
            username = tweet.user.screen_name.to_s

            next if twitter_users_passed.include?(username)
            twitter_users_passed << username

            # dont follow people we previously have
            entry = TwitterFollow.where(user: user, username: username)
            next if entry.present?

            client.follow(username)
            TwitterFollow.follow(user, username)
          end
          
        rescue Twitter::Error::TooManyRequests => e
          sleep_time = (e.rate_limit.reset_in + 1.minute)/60
          follow_prefs.rate_limit_until = DateTime.now + sleep_time.minutes
          follow_prefs.save
          puts "Sleeping until: #{follow_prefs.rate_limit_until}: #{user.email}"
        rescue => e
          Raygun.track_exception(e)
        end
      end
    end
  end
end