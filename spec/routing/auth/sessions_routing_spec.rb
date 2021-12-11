require "rails_helper"

RSpec.describe Auth::SessionsController, type: :routing do
  describe "routing" do
    it "routes to #login" do
      expect(post: "api/login").to route_to("auth/sessions#create")
    end

    it "routes to #logout" do
      expect(delete: "api/logout").to route_to("auth/sessions#destroy")
    end
  end
end
