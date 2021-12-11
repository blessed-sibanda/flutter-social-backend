json.cache! [@posts] do
  json.partial! "shared/pagination", url: posts_url, data: @posts, per_page: Post.per_page

  json.data @posts, partial: "posts/post_details", as: :post, cached: true
end
