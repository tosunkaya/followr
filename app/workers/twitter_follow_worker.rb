class TwitterFollowWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { hourly.minute_of_hour(0, 5, 10, 15, 20, 25,  30, 35,  40, 45, 50, 55) }

  def perform
    unless ENV['WORKERS_DRY_RUN'].blank?
      puts "TwitterFollowWorker run but returning due to WORKERS_DRY_RUN env variable"
      return
    end

    User.wants_twitter_follow.find_each do |user|
      begin
        # Keep track of # of followers user has hourly
        # TODO This should go in its own worker
        Stat.compose(user) if Stat.can_compose_for?(user)

        next if !user.twitter_check? || user.rate_limited? || !user.can_twitter_follow?

        hashtags = user.hashtags
        results = hashtags.flat_map do |hashtag|
          # Take at most 100 tweets in total to examine, divided by hashtag
          # 100 is the max page size for a twitter search -> we make sure that we're doing
          # at most 1 HTTP request per hashtag
          client.search("##{hashtag}").take((100 / hashtags.count).round).map do |tweet|
            { hashtag: hashtag, uid: tweet.user.id, username: tweet.user.screen_name }
          end
        end

        # Exclude all the users already followed in the past, with 1 query to the DB
        already_followed_uids = user.follows.where(uid: results.pluck(:uid).uniq).select(:uid)
        new_follows = results.reject { |r| already_followed_uids.include? o[:uid] }

        # TODO order by some euristics to pick the best ones instead of shuffling
        new_follows.sample(15).each do |r|
          user.follow!(r[:uid], r[:username], r[:hashtag])
        end

      rescue Twitter::Error::TooManyRequests => e
        # rate limited - set rate_limit_until timestamp
        sleep_time = (e.rate_limit.reset_in + 1.minute) rescue 16.minutes
        user.account.update_attributes!({ rate_limit_until: DateTime.now + sleep_time })
      rescue Twitter::Error::Forbidden => e
        # Airbrake.notify(e)
        puts e
      rescue Twitter::Error::Unauthorized => e
        user.credential.update_attributes!(is_valid: false)
      rescue => e
        Airbrake.notify(e)
      end
    end
  end
end
