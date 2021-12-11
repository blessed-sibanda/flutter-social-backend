require "rails_helper"

RSpec.describe "Auth::Sessions", type: :request do
  let!(:user) { create :user }

  let(:valid_attributes) {
    {
      email: user.email,
      password: user.password,
    }
  }

  let(:valid_headers) do
    { 'Authorization': token_for(user) }
  end

  describe "POST /api/login" do
    it "returns 401 unauthorized when invalid credentials are given" do
      post user_session_url, xhr: true, params: {
                               user: {
                                 email: "some-random-email@example.com",
                                 password: "very wrong password",
                               },
                             }
      expect(response).to have_http_status(:unauthorized)
    end

    context "correct credentials" do
      it "returns 401 unauthorized for unconfirmed user" do
        user = create :user, :unconfirmed
        valid_attributes[:email] = user.email
        post user_session_url, xhr: true,
                               params: {
                                 user: valid_attributes,
                               }
        expect(response).to have_http_status(:unauthorized)
      end

      it "succeeds" do
        user = create :user
        post user_session_url, xhr: true,
                               params: {
                                 user: valid_attributes,
                               }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "DELETE /api/logout" do
    it "returns no-content" do
      delete destroy_user_session_url, xhr: true, headers: valid_headers
      expect(response).to have_http_status(:no_content)
    end

    it "revokes the token" do
      delete destroy_user_session_url, xhr: true, headers: valid_headers
      get "/users/#{user.id}",
          xhr: true,
          headers: valid_headers
      expect(response.body).to eq "revoked token"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
