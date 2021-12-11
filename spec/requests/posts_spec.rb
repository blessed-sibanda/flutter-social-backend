require "rails_helper"

RSpec.describe "/posts", type: :request do
  let!(:user) { create :user }
  let!(:post1) { create :post }

  let(:valid_attributes) {
    {
      body: "My awesome post",
    }
  }

  let(:invalid_attributes) {
    {
      body: "",
    }
  }

  let!(:valid_headers) {
    {
      'Authorization': token_for(user),
    }
  }

  describe "PUT /like" do
    let!(:post1) { create :post }

    it "returns 401 unauthorized when user is unauthenticated" do
      put like_post_url(post1), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "likes post" do
      put like_post_url(post1), as: :json, headers: valid_headers
      post1.reload
      expect(post1.likes.count).to eq 1
    end
  end

  describe "PUT /unlike" do
    let!(:post1) { create :post }

    it "returns 401 unauthorized when user is unauthenticated" do
      put unlike_post_url(post1), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "unlikes post" do
      create :like, likable: post1, user: user
      expect(post1.reload.likes.count).to eq 1
      put unlike_post_url(post1), as: :json, headers: valid_headers
      expect(post1.reload.likes.count).to eq 0
    end
  end

  describe "GET /index" do
    it "renders a successful response" do
      create(:post)
      get posts_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end

    it "returns paginated posts in descending order" do
      random_paginable_data(:post, per_page: Post.per_page)

      expect_correct_paginated_result(
        data: Post.all,
        url: posts_url,
        base_class: Post,
        desc: true,
        fields: [:body, :post_id, :id],
        nested_fields: { user: [:id, :name] },
      )
    end

    it "returns # of likes for each post" do
      random = rand(10)
      create_list :like, random, likable: post1
      get posts_url, headers: valid_headers, as: :json
      expect(json["data"][0]["likes"]).to eq random
    end

    it "returns image_url for posts with images" do
      # first create post with image
      valid_attributes[:image] = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/user.jpg")
      post posts_url, xhr: true,
                      params: { post: valid_attributes }, headers: valid_headers

      get posts_url, headers: valid_headers, as: :json
      expect(json["data"][0]["image_url"]).not_to be_nil
    end

    it "returns 401 unauthorized when user is unauthenticated" do
      get posts_url, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /show" do
    context "authenticated user" do
      it "renders a successful response" do
        get post_url(post1), headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
      end

      it "returns post details" do
        get post_url(post1), headers: valid_headers, as: :json
        expect(json["body"]).to eq post1.body
        expect(json["created_at"]).to eq JSON.parse(post1.created_at.to_json)

        expect(json["user"]["id"]).to eq post1.user.id
        expect(json["user"]["name"]).to eq post1.user.name
        expect(json["user"]["email"]).to be_nil
      end
    end

    it "returns 401 unauthorized when user is unauthenticated" do
      get post_url(create :post), as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /create" do
    it "returns 401 unauthorized when user is unauthenticated" do
      post posts_url,
           params: { post: valid_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "with valid parameters" do
      it "creates a new Post" do
        expect {
          post posts_url,
               params: { post: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Post, :count).by(1)
        expect(Post.last.image.persisted?).to be_nil
      end

      it "renders a JSON response with the new post" do
        post posts_url,
             params: { post: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end

      it "creates a new post with image" do
        valid_attributes[:image] = Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/user.jpg")
        post posts_url, xhr: true,
                        params: { post: valid_attributes }, headers: valid_headers
        expect(Post.last.image.persisted?).not_to be_nil
        expect(Post.last.body).to eq valid_attributes[:body]
      end
    end

    context "with invalid parameters" do
      it "does not create a new Post" do
        expect {
          post posts_url,
               params: { post: invalid_attributes }, as: :json
        }.to change(Post, :count).by(0)
      end

      it "renders a JSON response with errors for the new post" do
        post posts_url,
             params: { post: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:post1) { create :post, user: user }

    it "returns 401 unauthorized when user is unauthenticated" do
      delete post_url(post1), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 forbidden when user is not owner of post" do
      delete post_url(create(:post)), headers: valid_headers, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(json["message"]).to eq "Only the author of the post is allowed perform this operation"
    end

    it "destroys the requested post" do
      expect {
        delete post_url(post1), headers: valid_headers, as: :json
      }.to change(Post, :count).by(-1)
    end
  end

  describe "GET /users/:id/posts" do
    let!(:user) { create :user }

    it "returns 401 unauthorized for unauthenticated user" do
      get posts_user_url(user), xhr: true
      expect(response).to have_http_status(:unauthorized)
    end

    context "authenticated user" do
      it "should return a successful response" do
        get posts_user_url(user), xhr: true, headers: { 'Authorization': token_for(create :user) }
        expect(response).to have_http_status(:ok)
      end

      it "returns user's posts in descending order" do
        user.posts << random_paginable_data(:post, per_page: Post.per_page)

        expect_correct_paginated_result(
          data: user.posts,
          url: posts_user_url(user),
          base_class: Post,
          fields: [:body, :id],
          desc: true,
        )
      end
    end
  end
end
