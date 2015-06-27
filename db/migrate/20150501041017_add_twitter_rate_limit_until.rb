class AddTwitterRateLimitUntil < ActiveRecord::Migration
  def change
  	add_column :twitter_follow_preferences, :rate_limit_until, :datetime
  end
end
