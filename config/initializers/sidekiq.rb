Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://rediscloud:GCe7BFNIIHx6hKeh@pub-redis-15178.us-east-1-3.2.ec2.garantiadata.com:15178' } if Rails.env.production?
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://rediscloud:GCe7BFNIIHx6hKeh@pub-redis-15178.us-east-1-3.2.ec2.garantiadata.com:15178' } if Rails.env.production?
end