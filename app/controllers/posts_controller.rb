class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[destroy show]
  before_action :verify_user, only: [:destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.page(params[:page]).per(Post.per_page).order(created_at: :desc)
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      render :show, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.require(:post).permit(:body)
  end

  def verify_user
    if current_user != @post.user
      render json: { message: "Only the author of the post is allowed perform this operation" }, status: :forbidden
    end
  end
end
