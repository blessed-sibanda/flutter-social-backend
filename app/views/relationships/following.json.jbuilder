json.cache! [@following] do
  json.partial! "shared/pagination", url: following_user_url(@user), data: @following, per_page: User.per_page

  json.data @following, partial: "users/user", as: :user, cached: true
end
