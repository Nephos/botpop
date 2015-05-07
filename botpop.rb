#!/usr/bin/env ruby
#encoding: utf-8

if RUBY_VERSION.split('.').first.to_i == 1
  raise RuntimeError, "#{__FILE__} is not compatible with Ruby 1.X."
end

require 'cinch'
require 'uri'
require 'net/ping'
require 'pry'
require 'yaml'
require 'colorize'

require_relative 'action'
require_relative 'arguments'

$botpod_arguments ||= ARGV

class Botpop

  ARGUMENTS = Arguments.new($botpod_arguments)
  VERSION = IO.read('version')
  CONFIG = YAML.load_file(ARGUMENTS.config_file)
  TARGET = /[[:alnum:]_\-\.]+/

  # Plugins loader
  Dir[File.expand_path '*.rb', ARGUMENTS.plugin_directory].each do |f|
    if !ARGUMENTS.disable_plugins.include? f
      puts "Loading plugin ... " + f.green + " ... " + require_relative(f).to_s
    end
  end
  prepend BotpopPlugins

  def start
    @engine.start
  end

  def initialize
    @engine = Cinch::Bot.new do
      configure do |c|
        c.server = ARGUMENTS.server
        c.channels = ARGUMENTS.channels
        c.ssl.use = ARGUMENTS.ssl
        c.port = ARGUMENTS.port
        c.user = ARGUMENTS.user
        c.nick = ARGUMENTS.nick
      end

      BotpopPlugins.constants.each do |const|
        if const =~ /\AMATCH_/
          BotpopPlugins.const_get(const).call(self)
        end
      end

    end
  end

end

if __FILE__ == $0
  Botpop.new.start
end
