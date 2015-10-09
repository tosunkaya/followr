class SessionsController < ApplicationController
  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_twitter_uid(auth["uid"])  || User.find_by_instagram_uid(auth["uid"])
    if user && user.credential
      c = user.credential
      if user.instagram_user?
        c.update_instagram_token(auth)
      else
        c.twitter_oauth_token = auth["extra"]["access_token"].params[:oauth_token]
        c.twitter_oauth_token_secret = auth["extra"]["access_token"].params[:oauth_token_secret]
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
