#!/usr/bin/env ruby
#encoding: utf-8

require 'cinch'
require 'uri'
require 'net/ping'
require 'pry'
require 'yaml'
require 'colorize'

require_relative 'action'
require_relative 'arguments'

$botpod_arguments = ARGV

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

      on :message, /coupon: .+/ do |m| BotpopPlugins::exec_coupon m end
      on :message, /\!(#{SEARCH_ENGINES.keys.join('|')}) .+/ do |m| BotpopPlugins::exec_search m end
      on :message, /!troll .+/ do |m| BotpopPlugins::exec_troll m end
      on :message, "!version" do |m| BotpopPlugins::exec_version m end
      on :message, "!code" do |m| BotpopPlugins::exec_code m end
      on :message, "!intra" do |m| BotpopPlugins::exec_intra m end
      on :message, "!intra on" do |m| BotpopPlugins::exec_intra_on m end
      on :message, "!intra off" do |m| BotpopPlugins::exec_intra_off m end
      on :message, "!ping" do |m| BotpopPlugins::exec_ping m end
      on :message, /!ping #{TARGET}\Z/ do |m| BotpopPlugins::exec_ping_target m end
      on :message, /!dos #{TARGET}\Z/ do |m| BotpopPlugins::exec_dos m end
      on :message, /!fok #{TARGET}\Z/ do |m| BotpopPlugins::exec_fok m end
      on :message, /!trace #{TARGET}\Z/ do |m| BotpopPlugins::exec_trace m end
      on :message, /!poke #{TARGET}\Z/ do |m| BotpopPlugins::exec_poke m end
      on :message, "!cmds" do |m| BotpopPlugins::exec_help m end
      on :message, "!help" do |m| BotpopPlugins::exec_help m end

    end
  end

end

if __FILE__ == $0
  Botpop.new.start
end
