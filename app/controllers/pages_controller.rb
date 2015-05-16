class PagesController < ApplicationController
	helper :application

	def index
		redirect_to dashboard_path if current_user
	end

	def dashboard
		redirect_to root_path and return if current_user.nil?

		if new_user?
			flash[:notice] = "It looks like you're just getting started - <a href='#{edit_twitter_follow_preference_path(current_user.twitter_follow_preference)}'>Set my follow preferences now</a>".html_safe
		end

		@followed_users_count = current_user.twitter_follow.count
		@began_following_users = current_user.twitter_follow.first.created_at.to_date.strftime('%m/%d/%y') rescue nil if @followed_users_count > 0
		@followers = current_user.followers.last.count if current_user.followers.present?
	end
end
