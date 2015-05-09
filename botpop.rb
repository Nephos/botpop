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

$botpod_arguments ||= ARGV

class Botpop

  ARGUMENTS = Arguments.new($botpod_arguments)
  VERSION = IO.read('version')
  CONFIG = YAML.load_file(ARGUMENTS.config_file)
  TARGET = /[[:alnum:]_\-\.]+/

  # Plugins loader
  Dir[File.expand_path '*.rb', ARGUMENTS.plugin_directory].each do |f|
    if !ARGUMENTS.disable_plugins.include? f
      puts "Loading plugin file ... " + f.green + " ... " + require_relative(f).to_s
    end
  end

  def self.plugins
    @@plugins.dup
  end

  @@plugins = []
  BotpopPlugins.constants.each do |const|
    plugin = BotpopPlugins.const_get(const)
    next if not plugin.is_a? Module
    if plugin::DISABLED
      puts "Disabled plugin #{plugin}".yellow
      next
      end rescue nil
    puts "Load plugin #{plugin}".green
    prepend plugin
    @@plugins << plugin
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
  Botpop.new.start
end
