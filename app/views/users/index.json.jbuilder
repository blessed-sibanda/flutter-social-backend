current_page = params.fetch(:page, 1).to_i

json.cache! [@users] do
  json._links do
    json.url users_url(page: current_page)
    json.first_page users_url(page: 1)
    json.prev_page users_url(page: current_page - 1) if (current_page > 1)
    json.next_page users_url(page: current_page + 1) if @users.next_page
    json.last_page users_url(page: @users.total_pages)
  end
end

json.partial! "users/users", users: @users, cached: true
