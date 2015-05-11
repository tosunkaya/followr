class AddTwitterUserIdToTwitterFollow < ActiveRecord::Migration
  def change
  	add_column :twitter_follows, :twitter_user_id, :string
  end
end
