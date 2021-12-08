json.extract! post, :id, :body, :created_at, :updated_at
json.url post_url(post, format: :json)
json.user do
  json.partial! "users/user", user: post.user
end
