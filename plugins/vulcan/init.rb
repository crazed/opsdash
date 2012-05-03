module OpsDash
  module Plugins
    module Vulcan
      extend OpsDash::Plugin

      plugin do
        set :root, '/vulcan' # puts all of your routes starting at /test
        set :name, 'Vulcan' # this shows up in navigation menus
      end

      get '/', :name => 'Overview' do
        haml :index
      end

    end
  end
end
