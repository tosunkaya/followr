class Follow < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :username, :hashtag, :twitter_user_id
  validates_uniqueness_of :user_id, :scope => :username

  scope :recent, ->(limit = 200) { order('created_at desc').limit(limit) }

  def unfollow!
    return if unfollowed

    client = user.credential.twitter_client rescue nil
    client.unfollow(username)
    client.unmute(username)
    update_attributes!({ unfollowed: true, unfollowed_at: DateTime.now })
  end
end
