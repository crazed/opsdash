# Ops Dashboard
I'm attempting to create an easily extendible dashboard system for operations teams. This should provide views into what nodes are running on your network, and what each of them are doing. Idealling it will be collecting this data using MCollective, and LLDP.

## Writing a plugin
To write a plugin see the example plugin and be sure to add to the config.yaml file so the plugin is loaded. I'm using Sinatra::ConfigFile from sinatra-contrib in order to allow easy configuration per environment.
