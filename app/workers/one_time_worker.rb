class OneTimeWorker
  include Sidekiq::Worker

  def perform(user_id = nil)
    users = User.all if user_id.nil?
    users = User.where(id: user_id) unless user_id.nil?

    users.each do |user|
      client = Credential.find(user).twitter_client
      users_to_unfollow = user.twitter_follow
      users_to_unfollow.each do |followed_user|
        begin
          puts "One Time: #{user.email} - unfollow #{followed_user.username} - TwitterFollowID: #{followed_user.id}"
          client.unfollow(followed_user.username)
          followed_user.update_attributes({unfollowed: true, unfollowed_at:DateTime.now})
        rescue Twitter::Error::NotFound => e
          followed_user.update_attributes({unfollowed: true, unfollowed_at:DateTime.now})
        end
      end
    end
  end
end