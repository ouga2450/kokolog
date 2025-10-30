class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # name パラメータを許可
  def configure_permitted_parameters
    # サインアップ時（新規登録）
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])

    # アカウント更新時（編集）
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
