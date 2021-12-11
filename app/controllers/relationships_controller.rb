class RelationshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def followers
    @followers = User.page(params[:page]).per(User.per_page)
      .where(id: @user.follower_ids).order(:created_at)
  end

  def following
    @following = User.page(params[:page]).per(User.per_page)
      .where(id: @user.following_ids).order(:created_at)
  end

  def follow
    @user.followers << current_user unless @user = current_user
  end

  def unfollow
    @user.followers.delete current_user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
