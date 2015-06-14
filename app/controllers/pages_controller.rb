class PagesController < ApplicationController
	helper :application

	def index
		redirect_to dashboard_path if current_user
	end

	def dashboard
		redirect_to root_path and return if current_user.nil?

		@followed_users_count = current_user.twitter_follows.count
		@began_following_users = current_user.began_following_users
	end

	def admin
		redirect_to root_path and return unless current_admin

		@users = User.all
	end

	def unfollow
		begin
			client = current_user.credential.twitter_client rescue nil
			return if client.nil?
			followed_user = current_user.twitter_follows.where(username: params[:username], unfollowed: false)
			return if !followed_user
			unfollowed = client.unfollow(params[:username])
            followed_user.first.update_attributes({ unfollowed: true, unfollowed_at: DateTime.now }) if unfollowed.present?
		rescue => e
			puts e
		ensure
			render json: nil, status: :ok
		end
	end

end
