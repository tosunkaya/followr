class Credential < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :user

  before_save :validate_creds

  def self.create_with_omniauth(user, auth)
    puts "creating credential with omniauth"
    puts "\nUSER::#{user}"
    puts "\nAuth:::#{auth}\n\n"
    puts auth["extra"]["access_token"]
    puts "\n done creating credential"
    c = Credential.new
    c.user = user
    c.twitter_oauth_token = auth["extra"]["access_token"].params[:oauth_token]
    c.twitter_oauth_token_secret = auth["extra"]["access_token"].params[:oauth_token_secret]
    c.save!
  end

	def twitter_client
    client = Twitter::REST::Client.new do |c|
      c.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      c.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      c.access_token        = !twitter_oauth_token.nil? ? twitter_oauth_token : twitter_access_token
      c.access_token_secret = !twitter_oauth_token_secret.nil? ? twitter_oauth_token_secret : twitter_access_token_secret
    end

    return client
	end

  def validate_creds
    validity = true
      begin
        twitter_client.follow('!')
      rescue Twitter::Error::BadRequest => e
        validity = false if e.message.index('Bad Authentication data')
      ensure
        return validity
      end
    validity
  end

  def is_oauth?
    twitter_oauth_token.present? && twitter_oauth_token_secret.present?
  end
end
