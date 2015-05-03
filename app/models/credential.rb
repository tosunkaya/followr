class Credential < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :user

  before_save :validate_creds

	def twitter_client
	    client = Twitter::REST::Client.new do |c|
	      c.consumer_key        = twitter_consumer_key
	      c.consumer_secret     = twitter_consumer_secret
	      c.access_token        = twitter_access_token
	      c.access_token_secret = twitter_access_token_secret
	    end

	    return client
	end


  def validate_creds
    validity = true
      begin
        twitter_client.follow('!')
      rescue Twitter::Error::BadRequest => e
        validity = false if e.message.index('Bad Authentication data')
        # validity = true if e.message.index('No user matches for specified terms')
      ensure
        return validity
      end
    validity
  end
end
