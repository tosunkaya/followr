Rails.application.routes.draw do
  resources :twitter_follow_preferences, :only => [:edit, :update]

  resources :twitter_follows, :only => [:index]

  require "sidekiq/web"

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
  end if Rails.env.production?

  mount Sidekiq::Web, at: "/sidekiq"

  root to: 'pages#index'

  if Rails.env.production?
    get '404', :to => 'pages#index'
  end

  get '/dashboard' => 'pages#dashboard', as: 'dashboard'
  get '/admin' => 'pages#admin', as: 'admin'

  get "/auth/:provider/callback" => "sessions#create"
  get '/auth/failure' => 'pages#index'

  get "/logout" => "sessions#destroy", :as => :signout


  post '/unfollow' => 'pages#unfollow'

end
