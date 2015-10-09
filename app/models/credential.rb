class Credential < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :user

  attr_encrypted :twitter_oauth_token, :key => ENV['APPLICATION_SECRET_KEY']
  attr_encrypted :twitter_oauth_token_secret, :key => ENV['APPLICATION_SECRET_KEY']
  attr_encrypted :instagram_token, :key => ENV['APPLICATION_SECRET_KEY']

  def self.instagram_create_with_omniauth(user, auth)
    c = Credential.new
    c.user = user
    c.instagram_token = auth["credentials"]["token"]
    c.save!
  end

  def update_instagram_token(auth)
    self.instagram_token = auth["credentials"]["token"]
    self.save
  end

  def self.twitter_create_with_omniauth(user, auth)
    c = Credential.new
    c.user = user
    c.twitter_oauth_token = auth["extra"]["access_token"].params[:oauth_token]
    c.twitter_oauth_token_secret = auth["extra"]["access_token"].params[:oauth_token_secret]
    c.save!
  end

	def twitter_client
    return nil if [twitter_oauth_token, twitter_oauth_token_secret].include?(nil)

    client = Twitter::REST::Client.new do |c|
      c.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      c.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      c.access_token        = twitter_oauth_token
      c.access_token_secret = twitter_oauth_token_secret
    end

    return client
	end

end
