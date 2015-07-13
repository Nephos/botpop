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

require_relative 'arguments'
require_relative 'builtin'

require_relative "botpop_plugin_inclusion"

$botpod_arguments ||= ARGV

class Botpop

  # FIRST LOAD THE CONFIGURATION
  ARGUMENTS = Arguments.new($botpod_arguments)
  VERSION = IO.read('version')
  CONFIG = YAML.load_file(ARGUMENTS.config_file)
  TARGET = /[[:alnum:]_\-\.]+/

  PluginInclusion::plugins_include! ARGUMENTS

  # THEN LOAD / NOT THE PLUGINS
  def self.plugins_load!
    @@plugins = []
    BotpopPlugins.constants.each do |const|
      plugin = BotpopPlugins.const_get(const)
      next if not plugin.is_a? Module
      if plugin::ENABLED == false
        puts "Disabled plugin #{plugin}".yellow if $botpop_include_verbose != false
        next
      end rescue nil
      puts "Load plugin #{plugin}".green if $botpop_include_verbose != false
      # prepend plugin
      @@plugins << plugin
    end
  end
  plugins_load!

  def self.plugins
    @@plugins.dup
  end

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
      @@plugins.each do |plugin|
        puts "Load matchings of the plugin #{plugin}".green
        plugin::MATCH.call(self, plugin) rescue puts "No matching found for #{plugin}".red
      end
    end
  end

end

if __FILE__ == $0
  $bot = Botpop.new
  $bot.start
end
