json.cache! [@people] do
  json.partial! "shared/pagination", url: people_users_url, data: @people, per_page: User.per_page

  json.data @people, partial: "users/user", as: :user, cached: true
end
