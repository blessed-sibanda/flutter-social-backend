require "rails_helper"

RSpec.describe Auth::RegistrationsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "api/signup").to route_to("auth/registrations#create", format: "json")
    end

    it "routes to #update" do
      expect(put: "api/signup").to route_to("auth/registrations#update", format: "json")
    end

    it "routes to #destroy" do
      expect(delete: "api/signup").to route_to("auth/registrations#destroy", format: "json")
    end
  end
end
