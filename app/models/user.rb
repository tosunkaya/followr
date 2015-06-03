class User < ActiveRecord::Base
  has_many :twitter_follow
  has_many :followers

  has_one :credential, dependent: :destroy
  has_one :twitter_follow_preference, dependent: :destroy

  scope :wants_twitter_follow, -> { joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)').where('twitter_follow_preferences.mass_follow IS TRUE') }
  scope :wants_twitter_unfollow, -> { joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)').where('twitter_follow_preferences.mass_unfollow IS TRUE') }

  after_create :init_follow_prefs
  
  def self.create_with_omniauth(auth)
      create! do |user|  
        user.twitter_uid = auth["uid"]  
        user.twitter_username = auth["info"]['nickname']
        user.name = auth["info"]["name"]
        Credential.create_with_omniauth(user, auth)
      end
  end

  def init_follow_prefs
    fp = TwitterFollowPreference.new(user: self)
    twitter_follow_preference = fp
  end

  def rate_limited?
    twitter_follow_preference.rate_limit_until > DateTime.now
  end

  # true if all is good to start following
  def twitter_check?
    follow_prefs = self.twitter_follow_preference
    hashtags = follow_prefs.hashtags.gsub('#','').split(',')

    client = self.credential.twitter_client rescue nil
    return false if client.nil? || hashtags.empty? || !follow_prefs.want_mass_follow?
    true
  end

  def can_twitter_follow?
    return false if twitter_follow_preference.rate_limit_until > DateTime.now
    followed_in_last_hour = self.twitter_follow.where('followed_at > ?', 1.hour.ago) 
    followed_in_last_day = self.twitter_follow.where('followed_at > ?', 24.hours.ago)

    return false if followed_in_last_hour.count >= 30 || followed_in_last_day.count >= 720
    true
  end

  def can_twitter_unfollow?
    unfollowed_in_last_hour = self.twitter_follow.where('unfollowed_at > ?', 1.hour.ago) 
    unfollowed_in_last_day = self.twitter_follow.where('unfollowed_at > ?', 24.hours.ago)

    return false if unfollowed_in_last_hour.count >= 50 || unfollowed_in_last_day.count >= 900
    true
  end


end
