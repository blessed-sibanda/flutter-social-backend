require "rails_helper"

RSpec.describe "Relationships", type: :request do
  let!(:user) { create :user }

  let(:valid_headers) {
    {
      'Authorization': token_for(user),
    }
  }

  describe "GET /users/:id/is_following" do
    let!(:user1) { create :user }

    context "authenticated user" do
      it "returns true if requesting user is a follower" do
        user1.followers << user
        get is_following_user_url(user1), xhr: true, headers: valid_headers
        expect(json["result"]).to be_truthy
      end

      it "returns false if requesting user is not a follower" do
        get is_following_user_url(user), xhr: true, headers: valid_headers
        expect(json["result"]).to be_falsy
      end
    end

    it "returns 401 unauthorized for unauthenticated requests" do
      get is_following_user_url(user), xhr: true
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /users/:id/follow" do
    context "authenticated" do
      it "follows user" do
        user2 = create :user
        put follow_user_url(user2),
            xhr: true,
            headers: valid_headers
        expect(user2.reload.followers).to include(user)
        expect(user.reload.following).to include(user2)
      end

      it "cannot follow itself" do
        put follow_user_url(user),
            xhr: true,
            headers: valid_headers
        expect(user.reload.followers.count).to eq 0
        expect(user.reload.following.count).to eq 0
      end
    end

    it "returns 401 unauthorized for unauthenticated requests" do
      put follow_user_url(user), xhr: true
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PUT /users/:id/unfollow" do
    it "un-follows user" do
      user2 = create :user
      user2.followers << user
      expect(user2.reload.followers).to include(user)
      expect(user.reload.following).to include(user2)
      put unfollow_user_url(user2),
          xhr: true,
          headers: valid_headers
      expect(user2.reload.followers).to_not include(user)
      expect(user.reload.following).to_not include(user2)
    end

    it "returns 401 unauthorized for unauthenticated user" do
      put unfollow_user_url(user), xhr: true
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /followers" do
    it "returns 401 unauthorized for unauthenticated requests" do
      get followers_user_url(user), xhr: true
      expect(response).to have_http_status(:unauthorized)
    end

    context "authenticated user" do
      it "returns a successful response" do
        get followers_user_url(user), headers: valid_headers, as: :json
        expect(response).to have_http_status(:success)
      end

      it "returns paginated list of followers in ascending order" do
        user1 = create :user
        user1.followers << random_paginable_data(:user, per_page: User.per_page)

        expect_correct_paginated_result(
          data: user1.followers,
          url: followers_user_url(user1),
          base_class: User,
          desc: false,
          fields: [:name, :created_at, :id],
        )
      end
    end
  end

  describe "GET /following" do
    it "returns 401 unauthorized for unauthenticated requests" do
      get following_user_url(user), xhr: true
      expect(response).to have_http_status(:unauthorized)
    end

    context "authenticated user" do
      it "returns a successful response" do
        get following_user_url(user), headers: valid_headers, as: :json
        expect(response).to have_http_status(:success)
      end

      it "returns paginated list of following in ascending order" do
        user1 = create :user
        user1.following << random_paginable_data(:user, per_page: User.per_page)

        expect_correct_paginated_result(
          data: user1.following,
          url: following_user_url(user1),
          base_class: User,
          desc: false,
          fields: [:name, :created_at, :id],
        )
      end
    end
  end
end
