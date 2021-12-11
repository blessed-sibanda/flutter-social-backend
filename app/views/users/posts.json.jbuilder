json.cache! [@posts, @user] do
  json.partial! "shared/pagination", url: posts_user_url(@user), data: @posts, per_page: Post.per_page

  json.data @posts, partial: "posts/post", as: :post, cached: true
end
