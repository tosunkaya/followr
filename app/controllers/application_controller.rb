class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :current_admin

  def current_user
    @current_user || User.find(session[:user_id])
  end

  def current_admin
  	@current_admin || User.find(session[:user_id]).twitter_uid == '52296517'
  end

end
