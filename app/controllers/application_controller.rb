class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :set_user

  def after_sign_in_path_for(resource)
    session[:welcomed] = true

    if resource.onboarding_completed?
      home_path
    else
      onboarding_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def set_user
    @user = current_user
  end
end
