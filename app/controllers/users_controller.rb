class UsersController < ApplicationController
  before_action :authenticate_user!, only: :show

  def index
    @users = User.paginated(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end
end
