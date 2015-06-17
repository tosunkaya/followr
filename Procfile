web: bundle exec unicorn -c lib/unicorn/config.rb -p $PORT
worker: bundle exec sidekiq -c 10 -q default,1