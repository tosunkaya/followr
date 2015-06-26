class PagesController < ApplicationController
  helper :application

  def index
    redirect_to dashboard_path if current_user
  end

  def dashboard
    redirect_to root_path and return if current_user.nil?
    session[:user_id] = nil unless current_user.credential.is_valid?

    if current_user.stats.present?
      @followers_count = current_user.stats.last.follower_count
      yesterday = DateTime.now.in_time_zone.to_date - 1.day
      @yesterdays_followers = current_user.stats.select { |f| f.created_at.to_date == yesterday }.first.count rescue nil
    end

    @followed_users_count = current_user.follows.count
    @began_following_users = current_user.began_following_users
  end

end
