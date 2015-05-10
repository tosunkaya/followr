class TwitterFollowPreference < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :user

	def rate_limited?
		rate_limit_until > DateTime.now
	end
end
