class OneTimeWorker
  include Sidekiq::Worker

  def perform
    users = User.all
    users.each do |user|
      client = Credential.find(user).twitter_client
      users_to_unfollow = user.twitter_follow
      users_to_unfollow.each do |followed_user|
        begin
          client.unfollow(followed_user.username)
          followed_user.update_attributes({unfollowed: true, unfollowed_at:DateTime.now})
        rescue Twitter::Error::NotFound => e
          followed_user.update_attributes({unfollowed: true, unfollowed_at:DateTime.now})
        end
      end
    end
  end
end