json.partial! "users/user", user: @user
json.email @user.email

json.followers do
  current_page = params.fetch(:followers_page, 1).to_i
  followers = User.page(current_page).per(User.per_page).where(id: @user.follower_ids)
  json._links do
    json.url user_url(@user, followers_page: current_page)
    json.first_page user_url(@user, followers_page: 1)
    json.prev_page user_url(@user, followers_page: current_page - 1) if (current_page > 1)
    json.next_page user_url(@user, followers_page: current_page + 1) if followers.next_page
    json.last_page user_url(@user, followers_page: followers.total_pages)
  end

  json.partial! "users/users", users: followers
end

json.following do
  current_page = params.fetch(:following_page, 1).to_i
  following = User.page(current_page).per(User.per_page).where(id: @user.following_ids)

  json._links do
    json.url user_url(@user, following_page: current_page)
    json.first_page user_url(@user, following_page: 1)
    json.prev_page user_url(@user, following_page: current_page - 1) if (current_page > 1)
    json.next_page user_url(@user, following_page: current_page + 1) if following.next_page
    json.last_page user_url(@user, following_page: following.total_pages)
  end

  json.partial! "users/users", users: following
end

json.posts do
  current_page = params.fetch(:posts_page, 1).to_i
  posts = Post.page(current_page).per(Post.per_page).where(user_id: @user.id).order(created_at: :desc)

  json._links do
    json.url user_url(@user, posts_page: current_page)
    json.first_page user_url(@user, posts_page: 1)
    json.prev_page user_url(@user, posts_page: current_page - 1) if (current_page > 1)
    json.next_page user_url(@user, posts_page: current_page + 1) if posts.next_page
    json.last_page user_url(@user, posts_page: posts.total_pages)
  end

  json._pagination do
    json.per_page Post.per_page
    json.total_count posts.total_count
    json.count posts.count
    json.total_pages posts.total_pages
  end

  json.data posts, partial: "users/post", as: :post
end
