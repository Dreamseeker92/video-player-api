module ApiVideos
  class Router
    attr_reader :routes

    def initialize
      @routes = []
    end

    def match(route, *args)
      options = {}
      options = args.pop if args.last.is_a?(Hash)
      options[:default] ||= {}
      options[:method] ||= 'GET'

      dest = nil
      dest = args.pop if args.size > 0
      raise 'Too many args!' if args.size > 0

      sections = route.split('/').reject(&:empty?)

      regexp, vars =  parse_sections_to_regexp(sections)
      routes.push({
                    regexp: Regexp.new("^/#{regexp}$"),
                    vars: vars,
                    dest: dest,
                    method: options[:method],
                    options: options,
                  })
    end

    def post(route, *args)
      if args.last.is_a?(Hash)
        args.last = args.last.merge(method: 'POST')
      else
        args.push({method: 'POST'})
      end

      match(route, *args)
    end


    def check_url(env)
      url = env['PATH_INFO']
      method = env['REQUEST_METHOD']
      match_data = nil
      route = routes.detect do |r|
        match_data = r[:regexp].match(url)
        match_data && method == r[:method]
      end
      return nil unless route

      options = route[:options]
      params = options[:default].dup
      route[:vars].each_with_index { |v, i| params[v] = match_data.captures[i] }
      return get_dest(route[:dest], params) if route[:dest]

      get_dest("#{params["controller"]}##{params["action"]}", params)
    end

    private

    def get_dest(dest, routing_params = {})
      if dest =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        cont = Object.const_get("#{name}Controller")
        return cont.by_action($2, routing_params)
      end

      raise "No destination: #{dest.inspect}!"
    end

    def parse_sections_to_regexp(parts)
      vars = []
      parts.map! do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          "(.*)"
        else
          part
        end
      end

      [parts.join('/'), vars]
    end
  end

  class Application
    def draw_routes(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      raise "No routes!" unless @router

      @router.check_url env
    end

    def identify_controller_and_action(env)
      _, controller, action,  =  env["PATH_INFO"].split('/', 4)
      controller = "#{controller.capitalize}Controller"
      [Object.const_get(controller), action]
    end
  end
end