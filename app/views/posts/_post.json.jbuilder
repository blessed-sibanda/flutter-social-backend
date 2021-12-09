json.extract! post, :id, :body, :created_at, :updated_at
json.url post_url(post, format: :json)
json.likes post.likes.count

json.user do
  json.partial! "users/user", user: post.user
end

if post.image.persisted?
  json.image_url request.scheme + "://" + request.host + ":" + request.port.to_s + Rails.application.routes.url_helpers.rails_representation_url(post.image.variant(saver: { quality: 90 }).processed, only_path: true)
end
