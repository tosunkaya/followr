class User < ActiveRecord::Base
	has_many :twitter_follow
	has_many :credential
	has_one :twitter_follow_preference

	validates_presence_of :email

	scope :wants_twitter_follow, -> { joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)').where('twitter_follow_preferences.unfollow_after > ?', -1) }
end
