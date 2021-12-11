class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: :destroy
  before_action :set_post
  before_action :verify_user, only: :destroy

  def index
    @comments = Comment.page(params[:page]).per(Comment.per_page)
      .where(id: @post.comment_ids).order(:created_at)
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.post = @post
    @comment.user = current_user

    if @comment.save
      render :show, status: :created, location: post_comment_url(@post, @comment)
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def verify_user
    if current_user != @comment.user
      render json: { message: "Only the author of the comment is allowed perform this operation" }, status: :forbidden
    end
  end
end
