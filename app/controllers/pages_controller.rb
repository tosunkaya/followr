class PagesController < ApplicationController
  helper :application

  def index
    redirect_to dashboard_path if current_user
  end

  def dashboard
    redirect_to root_path and return if current_user.nil?
    session[:user_id] = nil unless current_user.credential.is_valid?

    if current_user.followers.present?
      @followers_count = current_user.followers.last.count
      yesterday = DateTime.now.in_time_zone.to_date - 1.day
      @yesterdays_followers = current_user.followers.select { |f| f.created_at.to_date == yesterday }.first.count rescue nil
    end
    # TODO add percent difference

    @followed_users_count = current_user.twitter_follows.count
    @began_following_users = current_user.began_following_users



  end

  def admin
    redirect_to root_path and return unless current_admin

    @users = User.all
  end
end
