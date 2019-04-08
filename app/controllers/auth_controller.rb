require_relative '../../lib/abstract_controller'

class AuthController < ApiVideos::AbstractController

  def new
    render_response :new
  end

  def create
    redirect_to 'videos'
  end

  def sign_in

  end

  def sign_out

  end
end