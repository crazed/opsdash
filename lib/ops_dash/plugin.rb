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
      register_links if plugin_settings[:register_links]
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
      options = args.extract_options!
      link = args.first
      register_link('GET', link, options[:name])
      record(:get, *args, &block)
    end

    def post(*args, &block)
      options = args.extract_options!
      link = args.first
      register_link('POST', link, options[:name])
      record(:post, *args, &block)
    end

    def delete(*args, &block)
      options = args.extract_options!
      link = args.first
      register_link('DELETE', link, options[:name])
      record(:delete, *args, &block)
    end

    def put(*args, &block)
      options = args.extract_options!
      link = args.first
      register_link('PUT', link, options[:name])
      record(:put, *args, &block)
    end

    private


    def register_link(method, link, name)
      plugin_settings[:register_links] ||= Array.new
      plugin_settings[:register_links] << { :method => method, :link => link, :name => name }
    end

    def register_links
      @app.add_opsdash_links(plugin_settings[:name], plugin_settings[:register_links])
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
