json.cache! [@followers] do
  json.partial! "shared/pagination", url: followers_user_url(@user), data: @followers, per_page: User.per_page

  json.data @followers, partial: "users/user", as: :user, cached: true
end
