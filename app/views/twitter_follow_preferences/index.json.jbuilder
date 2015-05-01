json.array!(@twitter_follow_preferences) do |twitter_follow_preference|
  json.extract! twitter_follow_preference, :id
  json.url twitter_follow_preference_url(twitter_follow_preference, format: :json)
end
