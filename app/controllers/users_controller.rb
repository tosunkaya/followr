class UsersController < ApplicationController

  def update
    begin
      u = User.find current_user.id
      u.email = params[:user][:email].downcase
      u.save!
    rescue => e
      Airbrake.notify(e)
    ensure
      redirect_to dashboard_path
    end
  end

end