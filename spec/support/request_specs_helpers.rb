module RequestSpecsHelpers
  def json
    JSON.parse(response.body)
  end

  def token_for(user)
    post "/api/login", xhr: true, params: {
                         user: {
                           email: user.email,
                           password: user.password,
                         },
                       }
    response.headers["Authorization"]
  end

  def get_link_by_text(html_body, text)
    doc = Nokogiri::HTML(html_body.encoded)

    loop do
      children = doc.children
      break if children.empty?

      if children.length == 1 &&
         children.first.text == text &&
         children.first.parent.name = "a"
        return children.first.parent
      end

      doc = children
    end
  end

  def random_paginable_data(entity, per_page:)
    lower = rand(3..5) * per_page
    upper = rand(6..8) * per_page
    random_count = rand(lower..upper)

    data_list = create_list entity.to_sym, random_count
    data_list.sample(random_count / 2)
  end

  def expect_correct_paginated_result(
    data:, url:, base_class:, desc: false, fields: [], nested_fields: {}
  )
    get url, headers: valid_headers, as: :json

    random_index = rand(0...base_class.per_page)
    id = json["data"][random_index]["id"].to_i
    item = base_class.find(id)

    fields.each do |field|
      field = field.to_s
      if (field == "created_at" || field == "updated_at")
        value = JSON.parse item[field].to_json
      else
        value = item[field]
      end
      expect(json["data"][random_index][field.to_s]).to eq value
    end

    nested_fields.each do |key, value|
      nested_item_id = item["#{key}_id"]
      nested_item = class_eval("#{key.capitalize}.#{:find}(#{nested_item_id})")

      value.each do |field|
        expect(json["data"][random_index][key.to_s][field.to_s]).to eq nested_item[field.to_s]
      end
    end

    if desc
      expect(json["data"][0]["id"] > json["data"][1]["id"]).to be_truthy
    else
      expect(json["data"][0]["id"] < json["data"][1]["id"]).to be_truthy
    end

    expect(json["_links"]["current_page"]).to eq "#{url}.json?page=1"
    expect(json["_links"]["prev_page"]).to be_nil
    expect(json["_links"]["next_page"]).to eq "#{url}.json?page=2"
    total_pages = (data.count.to_f / base_class.per_page).ceil
    expect(json["_links"]["last_page"]).to eq "#{url}.json?page=#{total_pages}"
    expect(json["_meta"]["total_count"]).to eq data.count
    expect(json["_meta"]["total_pages"]).to eq total_pages
    expect(json["_meta"]["current_page"]).to eq 1
    expect(json["data"].length <= base_class.per_page).to be_truthy

    get json["_links"]["next_page"], headers: valid_headers, as: :json
    expect(json["_links"]["prev_page"]).to eq "#{url}.json?page=1"
    expect(json["_meta"]["current_page"]).to eq 2

    get json["_links"]["last_page"], headers: valid_headers, as: :json
    expect(json["_links"]["next_page"]).to be_nil
    expect(json["_meta"]["current_page"]).to eq total_pages
  end
end

RSpec.configure do |c|
  c.include RequestSpecsHelpers, type: :request
end
