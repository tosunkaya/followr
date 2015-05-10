class RenameTwitterCredentials < ActiveRecord::Migration
  def change
  	remove_column :credentials, :twitter_consumer_key
  	remove_column :credentials, :twitter_consumer_secret
  	remove_column :credentials, :twitter_access_token
  	remove_column :credentials, :twitter_access_token_secret
  	add_column :credentials,  :encrypted_twitter_oauth_token_secret, :string
  end
end
