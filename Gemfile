source :rubygems
gem 'sinatra'
gem 'sinatra-advanced-routes'
gem 'json'
gem 'sinatra-contrib'
gem 'haml'

# Install gems from each plugin
Dir.glob(File.join(File.dirname(__FILE__), 'plugins', '**', 'Gemfile')) do |gemfile|
  eval(IO.read(gemfile), binding)
end
