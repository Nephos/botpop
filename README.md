# botpop
[![Code Climate](https://codeclimate.com/github/pouleta/botpop/badges/gpa.svg)](https://codeclimate.com/github/pouleta/botpop)

## Usage

Simply change in the code the channels / server (2 examples provided with the executable)

Ruby 2 or greater is required. To be compatible with Ruby 1.9, you can try :
``sed 's/prepend/include/g' -i botpop.rb`` but no garanties...

``bundle install`` to install the gems.


## Arguments
By default, only the first occurence of the argument will be used, unless specified.
- -c _OPTION_ : list of channels (default __equilibre__)
- -s _OPTION_ : server ip (default to __freenode__)
- -p _OPTION_ : port (default __7000__ or __6667__ if no ssl)
- --no-ssl : disable ssl (__enabled__ by default)
- -n _OPTION_ : change the __nickname__
- -u _OPTION_ : change the __username__
- --config _OPTION_ : change the plugin configuration file (default to ``modules_config.yml``)
- --plugin-directory _OPTION_ : change the directory where the plugins are installed (default ``plugins/``)
- --plugin-disable _OPTION_ : disable a plugin (can be specified many times)
- --debug _OPTION_ : enable the debug mod. It et a global __$debug_OPTION__ to true. (can be specified many times)

## Plugins

### Create your own
You can easy create your own plugins. The documentation will be finished later.

First, put your ruby code file in ``plugins/``, and put your code in the scope :
```ruby
module BotpopPlugins
   ...code...
end
```

### Matching messages
To create a matching to respond to a message, you have to specifie in your plugin :
```ruby
module BotpopPlugins
  MATCH_BASE = lambda do |parent|
    parent.on :message, /!command argumentregexp/ do |m| BotpopPlugins::exec_command m end
  end
  ...code
end
```

### Debugging easier
You can specify the --debug OPT option at program start.
It will define as many __$debug_OPT__ globals to enable debug on the plugins.

As example:
```ruby
# If debug enabled for this options and error occured
if $debug_plugin and variable == :failed
  binding.pry # user hand here
  # Obsiously, it is usefull to trylock a mutex before because the bot use
  # Threads and can call many times this binding.pry
end
```
