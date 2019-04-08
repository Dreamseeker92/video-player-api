require_relative 'routing'

module ApiVideos
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end

      app = get_rack_app(env)
      app.call(env)
    end
  end
end