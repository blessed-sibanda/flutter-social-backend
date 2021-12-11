json.cache! [@users] do
  json.partial! "shared/pagination", url: users_url, data: @users, per_page: User.per_page

  json.data @users, partial: "users/user", as: :user, cached: true
end
