require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/advanced_routes'
require 'yaml'
require 'json'
require 'haml'
require 'logger'

unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end

require_relative 'lib/ops_dash/plugin'
require_relative 'lib/ops_dash/framework'

module OpsDash
  class App < Sinatra::Base
    def self.log
      @logger ||= Logger.new(STDOUT)
    end

    register Sinatra::ConfigFile
    register Sinatra::AdvancedRoutes
    register OpsDash::Framework
    config_file 'config.yaml'
    require_relative 'routes/init'
    begin
      settings.plugins.each do |plugin|
        init = "plugins/#{plugin}/init.rb"
        File.exists?(init) ? require_relative(init) : log.debug("Skipping plugin '#{plugin}'.. #{init} does not exist.")
      end
      OpsDash::Plugins.constants.each do |plugin|
        register OpsDash::Plugins.const_get(plugin)
      end
    rescue Exception => e
      log.warn "Unexpected exception: #{e.to_s}"
      log.debug e.backtrace.join("\n\t")
    end

    log.debug "App root: #{settings.root}"
    each_route do |route|
      log.info "Route defined: #{route.file.gsub(settings.root+'/','')} #{route.verb} #{route.path}"
    end
  end
end
