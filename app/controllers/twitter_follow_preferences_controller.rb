class TwitterFollowPreferencesController < ApplicationController
  before_action :set_twitter_follow_preference, only: [:show, :edit, :update, :destroy]

  # GET /twitter_follow_preferences
  # GET /twitter_follow_preferences.json
  def index
    @twitter_follow_preferences = TwitterFollowPreference.all
  end

  # GET /twitter_follow_preferences/1
  # GET /twitter_follow_preferences/1.json
  def show
  end

  # GET /twitter_follow_preferences/new
  def new
    @twitter_follow_preference = TwitterFollowPreference.new
  end

  # GET /twitter_follow_preferences/1/edit
  def edit
  end

  # POST /twitter_follow_preferences
  # POST /twitter_follow_preferences.json
  def create
    @twitter_follow_preference = TwitterFollowPreference.new(twitter_follow_preference_params)

    respond_to do |format|
      if @twitter_follow_preference.save
        format.html { redirect_to @twitter_follow_preference, notice: 'Twitter follow preference was successfully created.' }
        format.json { render :show, status: :created, location: @twitter_follow_preference }
      else
        format.html { render :new }
        format.json { render json: @twitter_follow_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twitter_follow_preferences/1
  # PATCH/PUT /twitter_follow_preferences/1.json
  def update
    respond_to do |format|
      if @twitter_follow_preference.update(twitter_follow_preference_params)
        format.html { redirect_to @twitter_follow_preference, notice: 'Twitter follow preference was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_follow_preference }
      else
        format.html { render :edit }
        format.json { render json: @twitter_follow_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_follow_preferences/1
  # DELETE /twitter_follow_preferences/1.json
  def destroy
    @twitter_follow_preference.destroy
    respond_to do |format|
      format.html { redirect_to twitter_follow_preferences_url, notice: 'Twitter follow preference was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_follow_preference
      @twitter_follow_preference = TwitterFollowPreference.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_follow_preference_params
      params[:twitter_follow_preference]
    end
end
