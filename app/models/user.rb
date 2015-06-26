class User < ActiveRecord::Base
  default_scope -> { includes(:credential, :account) }

  has_many :follows, dependent: :destroy
  has_many :stats, dependent: :destroy

  has_one :credential, dependent: :destroy
  has_one :account, dependent: :destroy

  scope :wants_twitter_follow, -> { joins(:account, :credential).where({ account: { mass_follow: true }, credential: { is_valid: true }}) }
  scope :wants_twitter_unfollow, -> { joins(:account, :credential).where({ account: { mass_unfollow: true }, credential: { is_valid: true }}) }

  def self.find_or_create_by_omniauth!(auth)
    user = User.where(uid: auth["uid"]).take
    if user
      user.tap do |user|
        c = user.credential || user.build_credential
        c.oauth_token = auth["extra"]["access_token"].params[:oauth_token]
        c.oauth_token_secret = auth["extra"]["access_token"].params[:oauth_token_secret]
        c.is_valid = true
        c.save! if c.changed?
      end
    else
      create! do |user|
        user.uid = auth["uid"]
        user.username = auth["info"]['nickname']
        user.name = auth["info"]["name"]
        user.build_account
        user.build_credential({
          oauth_token: auth["extra"]["access_token"].params[:oauth_token],
          oauth_token_secret: auth["extra"]["access_token"].params[:oauth_token_secret]
        })
      end
    end
  end

  def rate_limited?
    account.rate_limited?
  end

  # true if all is good to start following
  def twitter_check?
    (credential.twitter_client rescue nil).nil? && !hashtags.empty? && account.want_mass_follow?
  end

  def can_twitter_follow?
    return false if !credential.is_valid || rate_limited?

    followed_in_last_hour = follows.where('followed_at > ?', 1.hour.ago).count
    followed_in_last_day = follows.where('followed_at > ?', 24.hours.ago).count

    followed_in_last_hour < 30 && followed_in_last_day < 720
  end

  def can_twitter_unfollow?
    return false unless credential.is_valid

    unfollowed_in_last_hour = follows.where('unfollowed_at > ?', 1.hour.ago).count
    unfollowed_in_last_day = follows.where('unfollowed_at > ?', 24.hours.ago).count

    unfollowed_in_last_hour.count < 50 && unfollowed_in_last_day.count < 900
  end

  def began_following_users
    follows.first.created_at.to_date rescue nil
  end

  def hashtags
    account.hashtags.gsub('#','').gsub(' ','').split(',') rescue []
  end

  def follow!(twitter_uid, username, hashtag)
    client = credential.twitter_client

    client.friendship_update(twitter_uid, { :wants_retweets => false })
    client.mute(twitter_uid) # don't show their tweets in our feed
    if client.follow(twitter_uid)
      follows.create!({
        username: username,
        followed_at: DateTime.now,
        hashtag: hashtag,
        uid: twitter_uid
      })
    else
      false
    end
  end

end
