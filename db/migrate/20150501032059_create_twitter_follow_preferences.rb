class CreateTwitterFollowPreferences < ActiveRecord::Migration
  def change
    create_table :twitter_follow_preferences do |t|
   	  t.integer :unfollow_after, default: -1
   	  t.text :hashtags

      t.references :user
      t.timestamps null: false
    end
  end
end