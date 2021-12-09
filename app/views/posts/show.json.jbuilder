json.partial! "posts/post", post: @post

json.comments do
  current_page = params.fetch(:comments_page, 1).to_i
  comments = Comment.page(current_page).per(Comment.per_page).where(id: @post.comment_ids).order(:created_at)

  json._links do
    json.url post_url(@post, comments_page: current_page)
    json.first_page post_url(@post, comments_page: 1)
    json.prev_page post_url(@post, comments_page: current_page - 1) if (current_page > 1)
    json.next_page post_url(@post, comments_page: current_page + 1) if comments.next_page
    json.last_page post_url(@post, comments_page: comments.total_pages)
  end

  json._pagination do
    json.per_page Comment.per_page
    json.total_count comments.total_count
    json.count comments.count
    json.total_pages comments.total_pages
  end

  json.data comments, partial: "comments/comment", as: :comment
end
