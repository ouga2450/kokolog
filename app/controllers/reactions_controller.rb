class ReactionsController < ApplicationController
  def show
    @date = parse_date(params[:date]) || Date.current
    @context = ReactionContext.new(user: current_user, date: @date)
  end

  private

  def parse_date(str)
    return nil if str.blank?
    Date.parse(str)
  rescue ArgumentError
    nil
  end
end
