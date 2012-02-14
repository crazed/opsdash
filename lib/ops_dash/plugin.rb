require 'backports/basic_object' unless defined? BasicObject

module OpsDash
  module Plugin
    def self.new(&block)
      ext = Module.new.extend(self)
      ext.class_eval(&block)
      ext
    end

    def self.extended(base)
      # we want to know the file path to a loaded plugin
      base.set :plugin_path, File.dirname(caller[0])
      base.set :load_views, true
      base.set :name, base.name
    end

    def plugin(&block)
      yield
    end

    def registered(app = nil, &block)
      @app = app
      load_views if plugin_settings[:load_views]
      register_plugin unless routes.empty?
      app ? replay(app) : record(:class_eval, &block)
      app.log.info "Loaded #{plugin_settings[:name]} successfully!"
    end

    def set(arg, value)
      plugin_settings[arg] = value
    end

    def plugin_settings
      @plugin_settings ||= Hash.new
    end

    def configure(*args, &block)
      record(:configure, *args) { |c| c.instance_exec(c, &block) }
    end

    # TODO: investigate why these are already defined by Sinatra
    # method_missing doesn't seem to pick these up since Sinatra::Base has set them
    def get(*args, &block)
      register_route(:get, *args, &block)
    end

    def post(*args, &block)
      register_route(:post, *args, &block)
    end

    def delete(*args, &block)
      register_route(:delete, *args, &block)
    end

    def put(*args, &block)
      register_route(:put, *args, &block)
    end

    def routes
      @routes ||= Array.new
    end

    private

    def prefix_route(route)
      route = route.strip_slashes
      if plugin_settings[:root]
        root = plugin_settings[:root].strip_slashes
        route = "/#{root}/#{route}"
      end
      route.chop_slash
    end

    def register_route(method, *args, &block)
      options = args.extract_options!
      link = prefix_route(args.first)
      routes << { :method => method, :link => link, :name => options[:name] }
      record(method, link, &block)
    end

    def register_plugin
      @app.register_opsdash_plugin(plugin_settings[:name], routes, plugin_settings[:root])
    end

    def load_views
      Dir.glob(File.join(plugin_settings[:plugin_path], 'views', '*.haml')) do |haml_file|
        @app.template haml_file.split('/').last.gsub('.haml','').to_sym do
          File.read(haml_file)
        end
      end
    end

    def record(method, *args, &block)
      recorded_methods << [method, args, block]
    end

    def replay(app)
      recorded_methods.each { |m, a, b| app.send(m, *a, &b) }
    end

    def recorded_methods
      @recorded_methods ||= Array.new
    end

    def method_missing(method, *args, &block)
      return super unless Sinatra::Base.respond_to? method
      record(method, *args, &block)
      DontCall.new(method)
    end

    class DontCall < ::BasicObject
      def initialize(method) @method = method end
      def method_missing(*) fail "not supposed to use result of #@method!" end
      def inspect; "#<#{self.class}: #{@method}>" end
    end

  end
end
