class User < ActiveRecord::Base
	has_many :twitter_follow
	has_many :followers

	has_one :credential, dependent: :destroy
	has_one :twitter_follow_preference, dependent: :destroy

	scope :wants_twitter_follow, -> { joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)').where('twitter_follow_preferences.mass_follow IS TRUE') }
	scope :wants_twitter_unfollow, -> { joins('INNER JOIN twitter_follow_preferences ON (users.id = user_id)').where('twitter_follow_preferences.mass_unfollow IS TRUE') }

	after_create :init_follow_prefs
	
	def self.create_with_omniauth(auth)
	    create! do |user|  
	      user.twitter_uid = auth["uid"]  
	      user.twitter_username = auth["info"]['nickname']
	      user.name = auth["info"]["name"]
	      Credential.create_with_omniauth(user, auth)
	    end
	end

	def init_follow_prefs
		fp = TwitterFollowPreference.new(user: self)
		twitter_follow_preference = fp
	end
end
