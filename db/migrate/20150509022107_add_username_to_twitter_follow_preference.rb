class AddUsernameToTwitterFollowPreference < ActiveRecord::Migration
  def change
  	add_column :users, :twitter_uid, :string
  	add_column :users, :name, :string
  end
end
