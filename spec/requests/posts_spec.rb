require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/posts", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # Post. As you add validations to Post, be sure to
  # adjust the attributes here as well.
  let!(:user) { create :user }

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

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # PostsController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let!(:valid_headers) {
    {
      'Authorization': token_for(user),
    }
  }

  describe "GET /index" do
    it "renders a successful response" do
      create(:post)
      get posts_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end

    it "returns 401 unauthorized when user is unauthenticated" do
      get posts_url, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      post1 = create(:post)
      get post_url(post1), headers: valid_headers, as: :json
      expect(response).to have_http_status(:ok)
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
      end

      it "renders a JSON response with the new post" do
        post posts_url,
             params: { post: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
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

  describe "PATCH /update" do
    let!(:post1) { create :post, user: user }

    let(:new_attributes) {
      {
        body: "New body updated**",
      }
    }

    it "returns 401 unauthorized when user is unauthenticated" do
      patch post_url(post1),
            params: { post: new_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 forbidden when user is not owner of post" do
      post1 = create(:post)
      patch post_url(post1),
            params: { post: new_attributes }, headers: valid_headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end

    context "with valid parameters" do
      it "updates the requested post" do
        patch post_url(post1),
              params: { post: new_attributes }, headers: valid_headers, as: :json
        post1.reload
        expect(post1.body).to eq "New body updated**"
      end

      it "renders a JSON response with the post" do
        patch post_url(post1),
              params: { post: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "renders a JSON response with errors for the post" do
        patch post_url(post1),
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
    end

    it "destroys the requested post" do
      expect {
        delete post_url(post1), headers: valid_headers, as: :json
      }.to change(Post, :count).by(-1)
    end
  end
end