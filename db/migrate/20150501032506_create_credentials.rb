class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
	    t.references :user
      
      t.string :twitter_consumer_key
      t.string :twitter_consumer_secret
      t.string :twitter_access_token
      t.string :twitter_access_token_secret

      t.timestamps null: false
    end
  end
end
