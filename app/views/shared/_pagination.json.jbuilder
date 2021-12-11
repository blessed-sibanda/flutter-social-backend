json._links do
  json.first_page "#{url}?page=#{data.current_page}"
  json.prev_page "#{url}?page=#{data.current_page - 1}" if (data.current_page > 1)

  json.current_page "#{url}?page=#{data.current_page}"

  json.next_page "#{url}?page=#{data.current_page + 1}" if data.next_page
  json.last_page "#{url}?page=#{data.total_pages}"
end

json._meta do
  json.per_page per_page
  json.count data.count
  json.total_count data.total_count
end
