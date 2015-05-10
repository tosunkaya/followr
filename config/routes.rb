Rails.application.routes.draw do
  resources :twitter_follow_preferences, :only => [:edit, :update]

  # resources :twitter_follows
  # resources :users
  require "sidekiq/web"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?

  mount Sidekiq::Web, at: "/sidekiq"


  root to: 'pages#index'

  get '/dashboard' => 'pages#dashboard', as: 'dashboard'

  get "/auth/:provider/callback" => "sessions#create"
  
  get "/logout" => "sessions#destroy", :as => :signout
  
  # get '/preferences/twitter' => 'twitter_follow_preferences#edit', as: 'twitter_follow_preference'
  # patch '/preferences/twitter' => 'twitter_follow_preferences#update'

end
