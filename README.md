# botpop
[![Code Climate](https://codeclimate.com/github/pouleta/botpop/badges/gpa.svg)](https://codeclimate.com/github/pouleta/botpop)

## Usage
Ruby 2 or greater is required. To be compatible with Ruby 1.9, you can try :
``sed 's/prepend/include/g' -i botpop.rb`` but no garanties...
``bundle install`` to install the gems.


## Arguments
By default, only the first occurence of the argument will be used, unless specified.
- --channels, -c _OPTION_ : list of channels (default __equilibre__)
- --ip, -s _OPTION_ : server ip (default to __freenode__)
- --port, -p _OPTION_ : port (default __7000__ or __6667__ if no ssl)
- --no-ssl : disable ssl (__enabled__ by default)
- --nick, -n _OPTION_ : change the __nickname__
- --user, -u _OPTION_ : change the __username__
- --config _OPTION_ : change the plugin configuration file (default to ``modules_config.yml``)
- --plugin-directory _OPTION_ : change the directory where the plugins are installed (default ``plugins/``)
- --plugin-disable _OPTION_ : disable a plugin (can be specified many times)
- --debug, -d _OPTION_ : enable the debug mod. It et a global __$debug_OPTION__ to true. (can be specified many times)

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

# Plugins
Some official plugins are developped. You can propose your own creation by pull request, or add snippets link to the wiki.

## List
- [Base](https://github.com/pouleta/botpop/blob/master/plugins/base.rb) : this is a basic plugin, providing __version, code, help, and troll__
- [Network](https://github.com/pouleta/botpop/blob/master/plugins/network.rb) : an usefull plugin with commands __ping, ping ip, ping http, traceroute, dos attack and poke__
- [Searchable](https://github.com/pouleta/botpop/blob/master/plugins/searchable.rb) : a little plugin providing irc research with engines like __google, wikipedia, ruby-doc, etc...__
- [Coupon](https://github.com/pouleta/botpop/blob/master/plugins/coupons.rb) : the original aim of the bot. It get coupons for the challenge __pathwar__
- [Intranet](https://github.com/pouleta/botpop/blob/master/plugins/intranet.rb) : an useless plugin to check the intranet of epitech

## Create your own
You can easy create your own plugins.

The bot is based on [Cinch framework](https://github.com/cinchrb/cinch/).
You should take the time to read the documentation before developping anything.

### Example of new plugin
A full example of plugin code is provided in the commented file : [Example of Fury Plugin](https://github.com/pouleta/botpop/blob/master/plugins/example.rb)

First, put your ruby code file in ``plugins/``, and put your code in the scope :
```ruby
module BotpopPlugins
  module MyFuryPlugin
    def self.exec_whatkingofanimal m
      m.reply "Die you son of a" + ["lion", "pig", "red panda"].shuffle.first + " !!"
    end
    ...code...
  end
end
```

### Matching messages
To create a matching to respond to a message, you have to specifie in your plugin :
```ruby
module BotpopPlugins
  module MyFuryPlugin
    MATCH = lambda do |parent|
      parent.on :message, /!whatkingofanimal.*/ do |m| BotpopPlugins::exec_whatkingofanimal m end
    end
    ...code...
  end
end
```

### Add entry to the !help command
The __official plugin__ [Base](https://github.com/pouleta/botpop/blob/master/plugins/base.rb) provides the command __!help__.

It list the avaliable commands of the plugins. You can add your help to your plugin by providing a __HELP__ constant.
__The strings should be as short as possible.__
You should write it like the following:
```ruby
module BotpopPlugins
  module MyFuryPlugin
    HELP = ["!whatkingofanimal", "!animallist", "!checkanimal [type]"]
    ...code...
  end
end
```

### Enable and disable plugin
You can enable or disable plugin by using the constant __ENABLED__.
It should be linked with the __Botpop::CONFIG__.
The constant must be defined by the developper of the plugin.
For example, you can implement it like :
```ruby
module BotpopPlugins
  module MyFuryPlugin
    CONFIG = Botpop::CONFIG['myfurry'] || raise(MissingConfigurationZone, 'myfurry')
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']
  end
end
```
Then, a simple line in the ``modules_configuration.yml`` file should be enough.
