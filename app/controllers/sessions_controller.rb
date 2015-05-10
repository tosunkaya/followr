class SessionsController < ApplicationController
	
	def create
	    auth = request.env["omniauth.auth"]
	    puts auth
	    user = User.find_by_twitter_uid(auth["uid"]) || User.create_with_omniauth(auth)
	    puts user
	    puts user.id

	    session[:user_id] = user.id
	    redirect_to root_url
	end


	def destroy  
	  session[:user_id] = nil
	  redirect_to root_url
	end  
end
