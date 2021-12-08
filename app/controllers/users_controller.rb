class UsersController < ApplicationController
  before_action :authenticate_user!, except: :index
  before_action :set_user, except: :index

  def index
    @users = User.page(params[:page]).per(User.per_page).order(:created_at)
  end

  def show
  end

  def follow
    @user.followers << current_user
  end

  def unfollow
    @user.fans.where(follower: current_user).first&.destroy
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
