# botpop

## Usage

Simply change in the code the channels / server (2 examples provided with the executable)

Ruby 2 or greater is required. To be compatible with Ruby 1.9, you can try :
``sed 's/prepend/include/g' -i botpop.rb`` but no garanties...

``bundle install`` to install the gems.


## Arguments

- -c : list of channels (default equilibre)
- -s : server ip (default to freenode)
- -p : port (default 7000 or 6667 if no ssl)
- --no-ssl : disable ssl (enabled by default)
- -n : nickname
- -u : username
- --config : change the plugin configuration file (default to ``modules_config.yml``)
- --plugin-directory : change the directory where the plugins are installed (default plugins/)
- --plugin-disable : disable a plugin (can be specified many times)

## Plugins

You can easy create your own plugins. The documentation will be finished later.

First, put your ruby code file in ``plugins/``, and put your code in the scope :
```ruby
module BotpopPlugins
   ...code...
end
```

You __have to create your own match__ for now in the main ``botpop.rb`` file.
It has to seems like :
```ruby
  on :message, /!command argumentregexp/ do |m| BotpopPlugins::exec_command m end
```
