json.cache! do
  if post.image.persisted?
    json.image_url request.scheme + "://" + request.host + ":" + request.port.to_s + Rails.application.routes.url_helpers.rails_representation_url(post.image.variant(saver: { quality: 90 }).processed, only_path: true)
  end
end
