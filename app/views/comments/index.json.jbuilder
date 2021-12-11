json.cache! [@comments] do
  json.partial! "shared/pagination", url: post_comments_url, data: @comments, per_page: Comment.per_page

  json.data @comments, partial: "comments/comment", as: :comment, cached: true
end
