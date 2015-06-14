class TwitterFollowsController < ApplicationController
 
  def index
    redirect_to root_url and return if !current_user
    @twitter_follows = current_user.twitter_follows.recent
  end

end
