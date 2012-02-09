module OpsDash
  module Framework
    module Helpers
      def navigation_links
        settings.navigation_links
      end

      def navigation_link_active?
        navigation_links.each do |plugin|
          regexp = Regexp.new('^'+Regexp.escape(plugin[:index]))
          return true if request.path =~ regexp
        end
        false
      end

      def plugin_link_name
        sidebar_links.each do |link|
          return link[:name] if link[:link] == request.path
        end
        nil
      end

      def plugin_name
        settings.navigation_links.each do |plugin|
          plugin[:links].each do |link|
            return plugin[:name] if link[:link] == request.path
          end
        end
        nil
      end

      def plugin
        navigation_links.each do |plugin|
          plugin[:links].each do |link|
            return plugin if link[:link] == request.path
          end
        end
        nil
      end

      def sidebar_links
        settings.navigation_links.each do |plugin|
          plugin[:links].each do |link|
            return plugin[:links] if link[:link] == request.path
          end
        end
        Array.new
      end

      def sidebar_link_active?(href)
        sidebar_links.each do |link|
          return true if request.path == href
        end
        false
      end
    end

    def self.registered(app)
      app.helpers OpsDash::Framework::Helpers
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
