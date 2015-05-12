class Follower < ActiveRecord::Base
	
  belongs_to :user

	def self.compose(user)
		begin
      client = user.credential.twitter_client rescue nil
      followers_count = client.followers.count rescue nil

      return if client.nil? || followers_count.nil?

      followers = user.followers

      options = {
        :source => 'twitter',
        :count => followers_count,
        :user => user
      }

      followers << Follower.new(options)

    rescue => e
    	Airbrake.notify(e)
    end
	end

  def self.can_compose_for?(user)
    last_entry = user.followers.order('created_at DESC').first rescue nil
    if last_entry && last_entry.to_date == Date.today
      return false 
    else
      return true
    end
  end
end