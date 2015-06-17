class AddInvalidToCredentials < ActiveRecord::Migration
  def change
  	add_column :credentials, :is_valid, :boolean, default: true
  end
end
