class Credential < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :user, :oauth_token, :oauth_token_secret

  attr_encrypted :oauth_token, :key => ENV['APPLICATION_SECRET_KEY']
  attr_encrypted :oauth_token_secret, :key => ENV['APPLICATION_SECRET_KEY']

	def twitter_client
    return nil if [oauth_token, oauth_token_secret].include?(nil)

    Twitter::REST::Client.new do |c|
      c.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      c.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      c.access_token        = oauth_token
      c.access_token_secret = oauth_token_secret
    end
	end

end
