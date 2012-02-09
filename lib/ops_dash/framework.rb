module OpsDash
  module Framework
    def self.registered(app)
      puts "Registered the opsdash framework!"
    end

    def add_opsdash_links(plugin_name, links=[])
      links.each do |link|
        raise "Invalid link definition!" unless link.has_key?(:link)
        log.debug "#{plugin_name} created a route: #{link[:method]} #{link[:link]}"
      end
      opsdash_links[plugin_name] = links
    end

    def opsdash_links
      @opsdash_links ||= Hash.new
    end

    def log
      @logger ||= Logger.new(STDOUT)
    end
  end
end
