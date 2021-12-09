json.partial! "posts/post", post: @post, cached: true

json.cache! [@comments] do
  json.comments do
    current_page = params.fetch(:comments_page, 1).to_i

    json._links do
      json.url post_url(@post, comments_page: current_page)
      json.first_page post_url(@post, comments_page: 1)
      json.prev_page post_url(@post, comments_page: current_page - 1) if (current_page > 1)
      json.next_page post_url(@post, comments_page: current_page + 1) if @comments&.next_page
      json.last_page post_url(@post, comments_page: @comments&.total_pages)
    end

    json._pagination do
      json.per_page Comment.per_page
      json.total_count @comments&.total_count
      json.count @comments&.count
      json.total_pages @comments&.total_pages
    end

    json.data @comments, partial: "comments/comment", as: :comment, cached: true
  end
end

json.cache! [@users_liked] do
  json.users_liked do
    current_page = params.fetch(:likes_page, 1).to_i

    json._links do
      json.url post_url(@post, likes_page: current_page)
      json.first_page post_url(@post, likes_page: 1)
      json.prev_page post_url(@post, likes_page: current_page - 1) if (current_page > 1)
      json.next_page post_url(@post, likes_page: current_page + 1) if @users_liked&.next_page
      json.last_page post_url(@post, likes_page: @users_liked&.total_pages)
    end

    json._pagination do
      json.per_page Like.per_page
      json.total_count @users_liked&.total_count
      json.count @users_liked&.count
      json.total_pages @users_liked&.total_pages
    end

    json.data @users_liked, partial: "users/user", as: :user, cached: true
  end
end
