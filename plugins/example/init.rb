module OpsDash
  module Plugins
    module TestPlugin
      extend OpsDash::Plugin

      plugin do
        set :root, 'test' # puts all of your routes starting at /test
      end

      get '/example1', :name => 'Example Page' do
        @page = 'example1'
        haml :test
      end

      get '/example2', :name => 'Another example!' do
        @page = 'example2'
        haml :test
      end

      get '/example3', :name => 'Final example' do
        @page = 'example3'
        haml :test
      end
    end

  end
end
