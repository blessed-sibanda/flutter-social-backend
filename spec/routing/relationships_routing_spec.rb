require "rails_helper"

RSpec.describe RelationshipsController, type: :routing do
  describe "routing" do
    it "routes to #follow" do
      expect(put: "/users/1/follow").to route_to("relationships#follow", id: "1")
    end

    it "routes to #unfollow" do
      expect(put: "/users/1/unfollow").to route_to("relationships#unfollow", id: "1")
    end

    it "routes to #followers" do
      expect(get: "/users/1/followers").to route_to("relationships#followers", id: "1")
    end

    it "routes to #following" do
      expect(get: "/users/1/following").to route_to("relationships#following", id: "1")
    end
  end
end
