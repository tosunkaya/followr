class RemoveTwitterOauthToken < ActiveRecord::Migration
  def change
  	rename_column :credentials, :twitter_oauth_token, :encrypted_twitter_oauth_token
  	remove_column :credentials, :twitter_oauth_token_secret, :string
  end
end
