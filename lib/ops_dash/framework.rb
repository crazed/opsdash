module OpsDash
  module Framework
    def self.registered(app)
      puts "Registered the opsdash framework!"
    end

    def register_opsdash_plugin(plugin_name, links, index='/')
      opsdash_plugins << { :name => plugin_name, :links => links, :index => index }
    end

    def opsdash_plugins
      @opsdash_plugins ||= Array.new
    end

    def log
      @logger ||= Logger.new(STDOUT)
    end
  end
end
