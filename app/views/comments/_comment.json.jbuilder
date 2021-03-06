json.cache! [comment] do
  json.extract! comment, :id, :body, :created_at, :updated_at, :post_id
  json.url post_comment_url(comment.post, comment, format: :json)
  json.user do
    json.partial! "users/user", user: comment.user
  end
end
