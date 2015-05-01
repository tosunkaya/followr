class CreateTwitterFollows < ActiveRecord::Migration
  def change
    create_table :twitter_follows do |t|
      t.references :user
      t.boolean :unfollowed
      t.string :username
      t.datetime :followed_at
      t.datetime :unfollowed_at

      t.timestamps null: false
    end
  end
end