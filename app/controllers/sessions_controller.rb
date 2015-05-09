class SessionsController < ApplicationController
	
	def create
	    auth = request.env["omniauth.auth"]
	    user = User.find_by_twitter_uid(auth["uid"]) || User.create_with_omniauth(auth)

	    session[:user_id] = user.id
	    redirect_to '/dashboard', :notice => "Signed in!"r
	end
end
