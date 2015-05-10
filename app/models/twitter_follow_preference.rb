class TwitterFollowPreference < ActiveRecord::Base
	belongs_to :user

	validates_presence_of :user
	validates :unfollow_after, numericality: { greater_than_or_equal_to: 0 }

	def rate_limited?
		rate_limit_until > DateTime.now
	end
end
