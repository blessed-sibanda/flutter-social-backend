json.cache! [user] do
  json.extract! user, :id, :name, :created_at, :updated_at

  json.url user_url(user, format: :json)

  json.partial! "users/user_image", user: user, cached: true
end
