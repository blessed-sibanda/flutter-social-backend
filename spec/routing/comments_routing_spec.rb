require "rails_helper"

RSpec.describe CommentsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "posts/10/comments").to route_to("comments#create", post_id: "10")
    end

    it "routes to #destroy" do
      expect(delete: "posts/12/comments/1").to route_to("comments#destroy", post_id: "12", id: "1")
    end
  end
end
