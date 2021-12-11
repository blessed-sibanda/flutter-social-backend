class UsersController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_user, only: %i[show posts]

  def index
    @users = User.page(params[:page]).per(User.per_page).order(:created_at)
  end

  def show
  end

  def me
    @user = current_user
    render :show
  end

  def posts
    @posts = Post.page(params[:page]).per(Post.per_page).where(user_id: @user.id).order(created_at: :desc)
  end

  def people
    @people = User.page(params[:page]).per(User.per_page)
      .where(id: current_user.who_to_follow.pluck(:id)).order(:created_at)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
