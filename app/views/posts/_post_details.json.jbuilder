json.cache! [post] do
  json.partial! "posts/post", post: post, cached: true

  json.user do
    json.partial! "users/user", user: post.user, cached: true
  end
end
