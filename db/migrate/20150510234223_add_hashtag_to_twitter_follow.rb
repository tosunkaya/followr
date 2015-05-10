class AddHashtagToTwitterFollow < ActiveRecord::Migration
  def change
  	add_column :twitter_follows, :hashtag, :string
  end
end
