json.array!(@twitter_follows) do |twitter_follow|
  json.extract! twitter_follow, :id
  json.url twitter_follow_url(twitter_follow, format: :json)
end
