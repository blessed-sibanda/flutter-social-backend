json._pagination do
  json.per_page User.per_page
  json.total_count users.total_count
  json.total_pages users.total_pages
  json.count users.count
end

json.data users, partial: "users/user", as: :user
