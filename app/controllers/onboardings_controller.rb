class OnboardingsController < ApplicationController
  before_action :complete_onboarding, only: :show

  def show;end

  private

  def complete_onboarding
    return if current_user.onboarding_completed?

    current_user.update!(onboarding_completed: true)
  end
end
