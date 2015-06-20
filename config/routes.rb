Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  require "sidekiq/web"
  authenticate :admin_user do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  resources :twitter_follow_preferences, path: 'twitter/preferences', :only => [:edit, :update]

  resources :twitter_follows, path: 'twitter/activity', :only => [:index] do
    post 'unfollow', on: :member
  end

  root to: 'pages#index'

  if Rails.env.production?
    get '404', :to => 'pages#index'
  end

  get '/dashboard' => 'pages#dashboard', as: 'dashboard'

  get "/auth/:provider/callback" => "sessions#create"
  get '/auth/failure' => 'pages#index'

  get "/logout" => "sessions#destroy", :as => :signout

end
