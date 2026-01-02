class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :top, :terms, :privacy ]
  def top; end
  def terms; end
  def privacy; end
end
