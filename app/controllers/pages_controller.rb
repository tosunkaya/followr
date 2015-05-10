class PagesController < ApplicationController
	helper :application

	def index
		redirect_to dashboard_path if current_user
	end

	def dashboard
		flash[:notice] = "It looks like you're just getting started - <a href='#{edit_twitter_follow_preference_path(current_user.twitter_follow_preference)}'>Set my follow preferences now</a>".html_safe if new_user?
		redirect_to root_path unless current_user
	end
end
