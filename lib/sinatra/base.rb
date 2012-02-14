module Sinatra
  module Templates
    def haml(template, options={}, locals={})
      if plugin
        plugin_template = (plugin[:index].strip_slashes + '_' + template.to_s).to_sym
        template = plugin_template if settings.templates[plugin_template]
      end
      render :haml, template, options, locals
    end
  end
end
