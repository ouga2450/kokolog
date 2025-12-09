class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def build_resource(hash = {})
    hash[:uid] = User.create_unique_string
    super
  end

  def update_resource(resource, params)
    return super if params["password"].present?

    resource.update_without_password(params.except("current_password"))
  end

  protected

  # name パラメータを許可
  def configure_permitted_parameters
    # サインアップ時（新規登録）
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])

    # アカウント更新時（編集）
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
