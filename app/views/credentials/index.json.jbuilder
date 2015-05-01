json.array!(@credentials) do |credential|
  json.extract! credential, :id
  json.url credential_url(credential, format: :json)
end
