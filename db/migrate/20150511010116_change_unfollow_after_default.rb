class ChangeUnfollowAfterDefault < ActiveRecord::Migration
  def change
  	change_column_default :twitter_follow_preferences, :unfollow_after, 1
  end
end
