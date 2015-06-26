class AccountsController < ApplicationController
  before_action :set_account, only: [:edit, :update]
  before_action :auth_user

  # GET /accounts/1/edit
  def edit
    flash[:notice] = nil
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to dashboard_path, notice: 'Preferences updated!' }
        format.json { render :show, status: :ok, location: dashboard_path }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_follow_preference
      @account = current_user.account
    end

    def auth_user
      redirect_to root_url if !current_user || current_user.account != @account
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:unfollow_after, :hashtags, :mass_follow, :mass_unfollow)
    end
end
