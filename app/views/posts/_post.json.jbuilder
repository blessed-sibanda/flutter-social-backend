json.cache! [post] do
  json.extract! post, :id, :body, :created_at, :updated_at
  json.url post_url(post, format: :json)
  json.likes post.likes.count

  json.partial! "posts/post_image", post: post, cached: true
end
