class AddIndexToUsername < ActiveRecord::Migration
  def change
    add_index :twitter_follows, :username
    add_index :twitter_follows, :user_id
  end
end
