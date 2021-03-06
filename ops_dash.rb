require 'rubygems'
require 'sinatra'
require 'sinatra/base'
require 'sinatra/config_file'
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

require_relative 'lib/core_ext/array'
require_relative 'lib/core_ext/string'
require_relative 'lib/sinatra/base'
require_relative 'lib/ops_dash/plugin'
require_relative 'lib/ops_dash/framework'

module OpsDash
  class App < Sinatra::Base
    register Sinatra::ConfigFile
    register OpsDash::Framework
    config_file 'config.yaml'
    require_relative 'routes/init'
    begin
      settings.plugins.each do |plugin|
        init = "plugins/#{plugin}/init.rb"
        File.exists?(init) ? require_relative(init) : log.warn("Skipping plugin '#{plugin}'.. #{init} does not exist.")
      end
      OpsDash::Plugins.constants.each do |plugin|
        register OpsDash::Plugins.const_get(plugin)
      end
    rescue Exception => e
      log.warn "Unexpected exception: #{e.to_s}"
      log.debug e.backtrace.join("\n\t")
    end

    configure do
      set :navigation_links, opsdash_plugins
    end

    log.debug "App root: #{settings.root}"
  end
end
