
# require "redis"

# What the timeout for killing busy workers is, in seconds
timeout ENV["TIMEOUT"] ? ENV["TIMEOUT"].to_i : 30

# Whether the app should be pre-loaded
preload_app true

# How many worker processes
worker_processes 2

# before/after forks
before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # If you are using Redis but not Resque, change this
  # if defined?(Resque)
  #   Resque.redis.quit
  #   Rails.logger.info('Disconnected from Redis')
  # end

  sleep 1
end

after_fork do |server, worker|
  GC.disable
  #Redis.current.quit if defined?(Redis) && Rails.env.production?

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection(
    Rails.application.config.database_configuration[Rails.env]
  )

  # If you are using Redis but not Resque, change this
  # if defined?(Resque)
  #   Resque.redis = ENV['REDIS_URI']
  #   Rails.logger.info('Connected to Redis')
  # end
end
