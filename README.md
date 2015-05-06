# botpop

## Usage

Simply change in the code the channels / server (2 examples provided with the executable)

It has been tested with ruby 2.2.

``bundle install`` to install the gems.


## Arguments

- -c : list of channels (default equilibre)
- -s : server ip (default to freenode)
- -p : port (default 7000 or 6667 if no ssl)
- --no-ssl : disable ssl (enabled by default)
- -n : nickname
- -u : username
- --config : change the plugin configuration file (default to ``plugins/config.yml``)

## Plugins

You can easy create your own plugins. The documentation will be done later.

For know, juste create a ruby code file, ``require_relative 'it'``, then put your plugin code in the scope
```ruby
BotpopPlugins::YouAwesomeNewPluginModule
```
You have to create your own match for know. The plugin system is in work.
