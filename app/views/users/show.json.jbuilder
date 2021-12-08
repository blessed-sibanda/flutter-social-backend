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
    json.last_page user_url(@user, followers_page: followers.count.zero? ? 1 : followers.total_pages)
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
    json.last_page user_url(@user, following_page: following.count.zero? ? 1 : following.total_pages)
  end

  json.following json.partial! "users/users", users: following
end
