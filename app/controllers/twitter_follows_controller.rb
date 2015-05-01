class TwitterFollowsController < ApplicationController
  before_action :set_twitter_follow, only: [:show, :edit, :update, :destroy]

  # GET /twitter_follows
  # GET /twitter_follows.json
  def index
    @twitter_follows = TwitterFollow.all
  end

  # GET /twitter_follows/1
  # GET /twitter_follows/1.json
  def show
  end

  # GET /twitter_follows/new
  def new
    @twitter_follow = TwitterFollow.new
  end

  # GET /twitter_follows/1/edit
  def edit
  end

  # POST /twitter_follows
  # POST /twitter_follows.json
  def create
    @twitter_follow = TwitterFollow.new(twitter_follow_params)

    respond_to do |format|
      if @twitter_follow.save
        format.html { redirect_to @twitter_follow, notice: 'Twitter follow was successfully created.' }
        format.json { render :show, status: :created, location: @twitter_follow }
      else
        format.html { render :new }
        format.json { render json: @twitter_follow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /twitter_follows/1
  # PATCH/PUT /twitter_follows/1.json
  def update
    respond_to do |format|
      if @twitter_follow.update(twitter_follow_params)
        format.html { redirect_to @twitter_follow, notice: 'Twitter follow was successfully updated.' }
        format.json { render :show, status: :ok, location: @twitter_follow }
      else
        format.html { render :edit }
        format.json { render json: @twitter_follow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /twitter_follows/1
  # DELETE /twitter_follows/1.json
  def destroy
    @twitter_follow.destroy
    respond_to do |format|
      format.html { redirect_to twitter_follows_url, notice: 'Twitter follow was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_twitter_follow
      @twitter_follow = TwitterFollow.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def twitter_follow_params
      params[:twitter_follow]
    end
end
