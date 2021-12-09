current_page = params.fetch(:page, 1).to_i

json._links do
  json.url posts_url(page: current_page)
  json.first_page posts_url(page: 1)
  json.prev_page posts_url(page: current_page - 1) if (current_page > 1)
  json.next_page posts_url(page: current_page + 1) if @posts.next_page
  json.last_page posts_url(page: @posts.total_pages)
end

json._pagination do
  json.per_page Post.per_page
  json.total_count @posts.total_count
  json.total_pages @posts.total_pages
end

json.data @posts, partial: "posts/post", as: :post