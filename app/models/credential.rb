class Credential < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :user

	def twitter_client
	    client = Twitter::REST::Client.new do |c|
	      c.consumer_key        = twitter_consumer_key
	      c.consumer_secret     = twitter_consumer_secret
	      c.access_token        = twitter_access_token
	      c.access_token_secret = twitter_access_token_secret
	    end

	    return client
	end
end
