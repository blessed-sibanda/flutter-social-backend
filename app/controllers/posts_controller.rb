class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[destroy show like unlike]
  before_action :verify_user, only: [:destroy]

  def index
    @posts = Post.page(params[:page]).per(Post.per_page).order(created_at: :desc)
  end

  def show
  end

  def like
    @post.likes.create user: current_user
  end

  def unlike
    current_user.likes.find_by(likable: @post)&.destroy
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      render :show, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:body, :image)
  end

  def verify_user
    if current_user != @post.user
      render json: { message: "Only the author of the post is allowed perform this operation" }, status: :forbidden
    end
  end
end
