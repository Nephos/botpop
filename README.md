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
- --config : change the plugin configuration file (default to ``modules_config.yml``)

## Plugins

You can easy create your own plugins. The documentation will be finished later.

First, put your ruby code file in ``plugins/``, and put your code in the scope :
```ruby
module BotpopPlugins
   ...code...
end
```

You have to create your own match for now in the main ``botpop.rb`` file.
