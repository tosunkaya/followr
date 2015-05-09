class PagesController < ApplicationController
	helper :application

	# def authorize
	# 	@client = TwitterOAuth::Client.new(
	# 	    :consumer_key => ENV['TWITTER_CONSUMER_KEY'],
	# 	    :consumer_secret => ENV['TWITTER_CONSUMER_SECRET'],
	# 	    :token => 'Q3f1vJin32VlrwMu1xGYAwEZ2ns6IFRD',
	# 	    :secret => 'FLyvhVSFJHX5z9SHTvY3uM2R7eW5OtCJ'
	# 	)

	# 	if @client.authorized?
	# 		redirect_to '/dashboard'
	# 	else
	# 		request_token = @client.request_token(:oauth_callback => ENV['TWITTER_CALLBACK_URL'])
	# 		redirect_to request_token.authorize_url
	# 	end
	# end

	def dashboard
		@user = current_user

	end
end
