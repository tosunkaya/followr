class SetUnfollowedDefaultToFalse < ActiveRecord::Migration
  def change
  	change_column :twitter_follows, :unfollowed, :boolean, default: :false
  end
end
