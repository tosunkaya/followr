require 'test_helper'

class TwitterFollowPreferencesControllerTest < ActionController::TestCase
  setup do
    @twitter_follow_preference = twitter_follow_preferences(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:twitter_follow_preferences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create twitter_follow_preference" do
    assert_difference('TwitterFollowPreference.count') do
      post :create, twitter_follow_preference: {  }
    end

    assert_redirected_to twitter_follow_preference_path(assigns(:twitter_follow_preference))
  end

  test "should show twitter_follow_preference" do
    get :show, id: @twitter_follow_preference
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @twitter_follow_preference
    assert_response :success
  end

  test "should update twitter_follow_preference" do
    patch :update, id: @twitter_follow_preference, twitter_follow_preference: {  }
    assert_redirected_to twitter_follow_preference_path(assigns(:twitter_follow_preference))
  end

  test "should destroy twitter_follow_preference" do
    assert_difference('TwitterFollowPreference.count', -1) do
      delete :destroy, id: @twitter_follow_preference
    end

    assert_redirected_to twitter_follow_preferences_path
  end
end
