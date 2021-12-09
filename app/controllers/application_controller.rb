class ApplicationController < ActionController::API
  include ActionController::Caching
  respond_to :json
end
