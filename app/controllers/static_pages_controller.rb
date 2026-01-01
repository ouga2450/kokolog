class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :top, :terms ]
  def top; end
  def terms; end
end
