class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, required: true
      t.string :password


      t.timestamps null: false
    end
  end
end