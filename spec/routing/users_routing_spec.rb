require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users").to route_to("users#index")
    end

    it "routes to #show" do
      expect(get: "/users/1").to route_to("users#show", id: "1")
    end

    it "routes to #people" do
      expect(get: "/users/people").to route_to("users#people")
    end

    it "routes to #me" do
      expect(get: "/users/me").to route_to("users#me")
    end

    it "routes to #posts" do
      expect(get: "/users/1/posts").to route_to("users#posts", id: "1")
    end
  end
end
