class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :set_user

  def after_sign_in_path_for(resource)
    home_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  protected

  def configure_permitted_parameters
    # サインアップ時（新規登録）
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])

    # アカウント更新時（編集）
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  private

  def set_user
    @user = current_user
  end
end
