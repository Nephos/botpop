#!/usr/bin/env ruby
#encoding: utf-8

require 'cinch'
require 'uri'
require 'net/ping'
require 'pry'
require 'yaml'

require_relative 'action'
require_relative 'arguments'

class Botpop

  VERSION = IO.read('version')
  TARGET = /[[:alnum:]_\-\.]+/

  Dir[File.expand_path "plugins/*.rb"].each{|f| require_relative(f)}
  prepend BotpopPlugins

  def start
    @engine.start
  end

  def initialize argv
    @engine = Cinch::Bot.new do
      @argv = Arguments.new argv
      configure do |c|
        c.server = @argv.server
        c.channels = @argv.channels
        c.ssl.use = @argv.ssl
        c.port = @argv.port
        c.user = @argv.user
        c.nick = @argv.nick
      end

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
  Botpop.new(ARGV).start
end
