require 'test_helper'

class TwitterFollowsControllerTest < ActionController::TestCase
  setup do
    @twitter_follow = twitter_follows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_follows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_follow" do
    assert_difference('TwitterFollow.count') do
      post :create, twitter_follow: {  }
    end

    assert_redirected_to twitter_follow_path(assigns(:twitter_follow))
  end

  test "should show twitter_follow" do
    get :show, id: @twitter_follow
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twitter_follow
    assert_response :success
  end

  test "should update twitter_follow" do
    patch :update, id: @twitter_follow, twitter_follow: {  }
    assert_redirected_to twitter_follow_path(assigns(:twitter_follow))
  end

  test "should destroy twitter_follow" do
    assert_difference('TwitterFollow.count', -1) do
      delete :destroy, id: @twitter_follow
    end

    assert_redirected_to twitter_follows_path
  end
end
