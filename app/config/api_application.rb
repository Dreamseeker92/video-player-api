abs_path = File.expand_path(File.join(File.dirname(__FILE__ ), "..",  "controllers"))
Dir["#{abs_path}/**/*.rb"].each do |fname|
  base_name = File.basename(fname, '.rb')
  const = base_name.split('_').map!(&:capitalize).join.to_sym
  autoload(const, fname)
end

#autoload(:VideosController, "#{abs_path}/videos_controller.rb")
require_relative '../../lib/application'
class App < ApiVideos::Application; end
