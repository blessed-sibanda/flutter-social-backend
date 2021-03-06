json._links do
  json.first_page "#{url}.json?page=#{data.current_page}"
  json.prev_page "#{url}.json?page=#{data.current_page - 1}" if (data.current_page > 1)

  json.current_page "#{url}.json?page=#{data.current_page}"

  json.next_page "#{url}.json?page=#{data.current_page + 1}" if data.next_page
  json.last_page "#{url}.json?page=#{data.total_pages}"
end

json._meta do
  json.per_page per_page
  json.count data.count
  json.total_count data.total_count
  json.total_pages data.total_pages
  json.current_page data.current_page
end
