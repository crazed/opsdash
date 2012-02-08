module OpsDash
  class App
    get '/' do
      haml :index
    end
  end
end
