class User < ActiveRecord::Base
	has_many :twitter_follow
	has_one :credential
	has_one :twitter_follow_preference

	# validates_presence_of :email

	scope :wants_twitter_follow, -> { joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)').where('twitter_follow_preferences.unfollow_after > ?', -1) }



	def self.create_with_omniauth(auth)  
	    create! do |user|  
	      user.twitter_uid = auth["uid"]  
	      user.name = auth["info"]["name"]
	    end
	end  
end
