class UsersController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_user, except: [:index, :find_people]

  def index
    @users = User.page(params[:page]).per(User.per_page).order(:created_at)
  end

  def find_people
    @users = User.page(params[:page]).per(User.per_page)
      .where(id: current_user.who_to_follow.pluck(:id)).order(:created_at)
  end

  def show
    current_page = params.fetch(:followers_page, 1).to_i
    @followers = User.page(current_page).per(User.per_page).where(id: @user.follower_ids).order(:created_at)

    current_page = params.fetch(:following_page, 1).to_i
    @following = User.page(current_page).per(User.per_page).where(id: @user.following_ids).order(:created_at)

    current_page = params.fetch(:posts_page, 1).to_i
    @posts = Post.page(current_page).per(Post.per_page).where(user_id: @user.id).order(created_at: :desc)
  end

  def follow
    @user.followers << current_user
  end

  def unfollow
    @user.followers.delete current_user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
