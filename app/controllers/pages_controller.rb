class PagesController < ApplicationController
	helper :application


	def index

	end

	def dashboard
		redirect_to root_path if current_user.nil?
		binding.pry

	end
end
