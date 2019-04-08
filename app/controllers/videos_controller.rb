require_relative '../../lib/abstract_controller'

class VideosController < ApiVideos::AbstractController
  def index
    render_response :index,  noun: 'Hello world'
  end
end