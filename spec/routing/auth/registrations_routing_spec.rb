require "rails_helper"

RSpec.describe Auth::RegistrationsController, type: :routing do
  describe "routing" do
    it "routes to #create" do
      expect(post: "api/signup").to route_to("auth/registrations#create")
    end

    it "routes to #update" do
      expect(put: "api/signup").to route_to("auth/registrations#update")
    end

    it "routes to #destroy" do
      expect(delete: "api/signup").to route_to("auth/registrations#destroy")
    end
  end
end
