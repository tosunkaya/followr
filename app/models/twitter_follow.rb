class TwitterFollow < ActiveRecord::Base
	belongs_to :user
	validates_presence_of :username
 	validates_uniqueness_of :user_id, :scope => :username

	def self.follow(user, username, hashtag, twitter_user_id)
	    entry = TwitterFollow.new
	    entry.user_id = user.id
	    entry.username = username
	    entry.followed_at = DateTime.now
	    entry.hashtag = hashtag
	    entry.twitter_user_id = twitter_user_id
	    entry.save
	end
end
