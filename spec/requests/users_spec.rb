require "rails_helper"

RSpec.describe "Users", type: :request do
  let!(:user) { create :user }

  let(:valid_headers) do
    { 'Authorization': token_for(user) }
  end

  describe "GET /users" do
    it "returns http success" do
      create_list :user, 3
      get "/users", xhr: true
      expect(response).to have_http_status(:success)
    end

    it "returns a paginated list of users without email addresses" do
      random_paginable_data(:user, per_page: User.per_page)

      expect_correct_paginated_result(
        data: User.all,
        url: users_url,
        base_class: User,
        desc: false,
        fields: [:name, :id],
      )
    end
  end

  describe "GET /users/:id" do
    let!(:user) { create :user }

    context "authenticated user" do
      it "returns user email" do
        @token = token_for(user)
        get "/users/#{user.id}",
            xhr: true,
            headers: { 'Authorization': @token }
        expect(json["email"]).not_to be_nil
        expect(response).to have_http_status(:success)
      end

      context "with about info" do
        it "displays user about" do
          user = create :user, about: "This is my information"
          @opts = { xhr: true, headers: { 'Authorization': token_for(create :user) } }
          get "/users/#{user.id}", **@opts
          expect(json["about"]).to eq user.about
        end
      end
    end

    it "returns unauthorized for unauthenticated requests" do
      get "/users/#{User.all.sample.id}", xhr: true
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /users/me" do
    it "returns unauthorized for unauthenticated user" do
      get me_users_url, xhr: true
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the current user when request is authenticated" do
      get me_users_url, xhr: true, headers: valid_headers
      expect(json["email"]).to eq user.email
      expect(json["name"]).to eq user.name
      expect(json["about"]).to eq user.about
      expect(json["id"]).to eq user.id
    end
  end

  describe "GET /users/people" do
    it "returns 401 unauthorized when user is unauthenticated" do
      get people_users_url, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "authenticated request" do
      it "returns a successful response" do
        get people_users_url, as: :json, headers: valid_headers
        expect(response).to have_http_status(:success)
      end

      it "paginates list of people to follow (without email addresses)" do
        user.followers << random_paginable_data(:user, per_page: User.per_page)

        expect_correct_paginated_result(
          data: user.who_to_follow,
          url: people_users_url,
          base_class: User,
          fields: [:created_at, :name, :id],
        )
      end
    end
  end
end
