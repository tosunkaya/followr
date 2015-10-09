class AddInstagram < ActiveRecord::Migration
  def up
    add_column :users, :instagram_uid, :string
    add_column :users, :instagram_username, :string
    add_column :credentials, :encrypted_instagram_token, :string
  end

  def down
    remove_column :users, :instagram_uid, :string
    remove_column :users, :instagram_username, :string
    remove_column :credentials, :encrypted_instagram_token, :string
  end
end
