class AddMassFollowAndUnfollow < ActiveRecord::Migration
  def change
  	add_column :twitter_follow_preferences, :mass_follow, :boolean, default: true
  	add_column :twitter_follow_preferences, :mass_unfollow, :boolean, default: true
  end
end
