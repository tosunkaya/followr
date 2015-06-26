class FollowsController < ApplicationController

  def index
    redirect_to root_url and return if !current_user
    @follows = current_user.follows.recent
  end

  def unfollow
    begin
      @follow = current_user.follows.find(params[:id])
      @follow.unfollow!
      respond_to do |format|
        format.js { render inline: "$('#follow-#{@follow.id}').replaceWith('<%=j render partial: 'follow', locals: { follow: @follow} %>')" }
      end

    rescue => e
      Airbrake.notify(e)
      render js: "alert('Oops! It seems that something went wrong :(')"
    end
  end

end
