require 'erubis'
require 'rack/request'
require 'rack/response'

module ApiVideos
  class AbstractController
    attr_reader :env
    attr_accessor :routing_params

    def initialize(env)
      @env = env
      @routing_params = {}
    end

    def request
      @request = Rack::Request.new(env)
    end

    def params
      request.params.merge(routing_params)
    end

    def response(text, status=200, headers = {})
      raise "Already responded!" if @response

      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def dispatch(action, request_params)
      self.routing_params = request_params
      send(action)

      if get_response
        status, headers, resp = get_response.to_a
        [status, headers, [resp.body].flatten]
      else
        [404, {'Content-Type' => 'text/html'}, ["Not Found"]]
      end
    end

    def redirect_to(path)
      response([], 302, {'Location' =>"#{request.env['HTTP_HOST']}/#{path}"})
    end

    def get_response
      @response
    end

    def render_response(*args)
      response(render(*args))
    end

    def controller_name
      self.class.name.gsub('Controller', '').downcase
    end

    def render(action_name, locals = {})
      file_name = File.join('app', 'views', controller_name, "#{action_name}.html.erb")
      template = ::Erubis::Eruby.new(File.read(file_name))
      template.result(locals.merge(env: env))
    end

    class << self
      def by_action(action, request_params = {})
          proc { |env| self.new(env).dispatch(action, request_params) }
      end
    end
  end
end