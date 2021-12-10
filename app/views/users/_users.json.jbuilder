current_page = params.fetch(:page, 1).to_i

json.cache! [users] do
  json._pagination do
    json.per_page User.per_page
    json.total_count users.total_count
    json.total_pages users.total_pages
    json.count users.count
    json.page current_page
  end

  json.data users, partial: "users/user", as: :user, cached: true
end
