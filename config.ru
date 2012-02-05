require 'ops_dash'
disable :run

map '/' do
  run OpsDash::App
end
