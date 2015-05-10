class AddTwitterOauthParams < ActiveRecord::Migration
  def change
  	add_column :credentials, :twitter_oauth_token, :string
  	add_column :credentials, :twitter_oauth_token_secret, :string
  end
end
