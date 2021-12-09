require "rails_helper"

RSpec.describe UsersController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/users").to route_to("users#index")
    end

    it "routes to #follow" do
      expect(put: "/users/1/follow").to route_to("users#follow", id: "1")
    end

    it "routes to #unfollow" do
      expect(put: "/users/1/unfollow").to route_to("users#unfollow", id: "1")
    end

    it "routes to #show" do
      expect(get: "/users/1").to route_to("users#show", id: "1")
    end

    it "routes to #find_people" do
      expect(get: "/users/find_people").to route_to("users#find_people")
    end

    it "routes to #me" do
      expect(get: "/users/me").to route_to("users#me")
    end
  end
end
