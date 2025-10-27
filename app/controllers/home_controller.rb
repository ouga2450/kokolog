class HomeController < ApplicationController
  before_action :authenticate_user!  # ← ログイン必須

  def index
    @user = current_user
  end
end
