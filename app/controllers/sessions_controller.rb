class SessionsController < ApplicationController
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_twitter_uid(auth["uid"]) || User.find_by_instagram_uid(auth["uid"])
    if user && user.credential
      c = user.credential
      if user.instagram_user?
        c.update_instagram_token(auth)
      elsif user.twitter_user?
        c.update_twitter_tokens(auth)
      else 
        redirect_to root_url and return
      end
      c.is_valid = true
      c.save! if c.changed?
    else
      user = User.create_with_omniauth(auth)
    end
    session[:user_id] = user.id
    redirect_to dashboard_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
