require "rails_helper"

RSpec.describe "/comments", type: :request do
  let!(:user) { create :user }
  let!(:comment) { create :comment }

  let(:valid_attributes) {
    {
      body: "Wonderful post",
    }
  }

  let(:invalid_attributes) {
    {
      body: "",
    }
  }

  let(:valid_headers) {
    {
      'Authorization': token_for(user),
    }
  }

  describe "POST /create" do
    it "returns 401 unauthorized when user is unauthenticated" do
      post post_comments_url(comment.post), params: { comment: valid_attributes },
                                            as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "with valid parameters" do
      it "creates a new Comment" do
        expect {
          post post_comments_url(comment.post),
               params: { comment: valid_attributes }, headers: valid_headers, as: :json
        }.to change(Comment, :count).by(1)
      end

      it "renders a JSON response with the new comment" do
        post post_comments_url(comment.post),
             params: { comment: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Comment" do
        expect {
          post post_comments_url(comment.post),
               params: { comment: invalid_attributes }, as: :json
        }.to change(Comment, :count).by(0)
      end

      it "renders a JSON response with errors for the new comment" do
        post post_comments_url(comment.post, comment),
             params: { comment: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including("application/json"))
      end
    end
  end

  describe "DELETE /destroy" do
    it "returns 401 unauthorized when user is unauthenticated" do
      delete post_comment_url(comment.post, comment), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 403 forbidden when user is not owner of comment" do
      delete post_comment_url(comment.post, comment), headers: valid_headers, as: :json
      expect(response).to have_http_status(:forbidden)
      expect(json["message"]).to eq "Only the author of the comment is allowed perform this operation"
    end

    it "destroys the requested comment" do
      c = create :comment, user: user
      expect {
        delete post_comment_url(c.post, c), headers: valid_headers, as: :json
      }.to change(Comment, :count).by(-1)
    end
  end

  describe "GET /index" do
    let(:post1) { create :post }

    it "returns 401 unauthorized when user is unauthenticated" do
      get post_comments_url(post1), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    context "authenticated user" do
      it "returns a successful response" do
        get post_comments_url(post1), headers: valid_headers, as: :json
        expect(response).to have_http_status(:success)
      end

      it "returns post's comments" do
        post1.comments << random_paginable_data(:comment, per_page: Comment.per_page)

        expect_correct_paginated_result(
          data: post1.comments,
          url: post_comments_url(post1),
          base_class: Comment,
          fields: [:body, :post_id, :id],
          nested_fields: { user: [:id, :name] },
        )
      end
    end
  end
end
