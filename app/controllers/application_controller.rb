class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :current_admin, :new_user?

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def current_admin
    current_user && current_user.twitter_username == 'plaintshirts'
  end

  def new_user?
    return unless current_user
    twitter_follow_preference = current_user.twitter_follow_preference
    !(current_user.created_at < 4.hours.ago) && twitter_follow_preference.present? && twitter_follow_preference.hashtags.blank?
  end
end