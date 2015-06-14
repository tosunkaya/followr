class TwitterFollowsController < ApplicationController
 
  def index
    redirect_to root_url and return if !current_user
    @twitter_follows = current_user.twitter_follows.recent
  end

  def unfollow
    begin
      @twitter_follow = current_user.twitter_follows.find(params[:id])
      @twitter_follow.unfollow!
      respond_to do |format|
        format.js { render inline: "$('#follow-#{@twitter_follow.id}').replaceWith('<%=j render partial: 'twitter_follow', locals: { twitter_follow: @twitter_follow} %>')" }
      end

    rescue => e
      Airbrake.notify(e)
      render js: "alert('Oops! It seems that something went wrong :(')"
    end
  end

end
