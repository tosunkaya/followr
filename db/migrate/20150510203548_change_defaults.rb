class ChangeDefaults < ActiveRecord::Migration
  def change
    change_column_default :twitter_follow_preferences, :unfollow_after, 0
    change_column_default :twitter_follow_preferences, :hashtags, ''
  end
end
