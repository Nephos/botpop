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

  SEARCH_ENGINES = YAML.load_file(Arguments.new(ARGV).config_file)["search_engines"]
  SEARCH_ENGINES_VALUES = SEARCH_ENGINES.values.map{|e|"!"+e}.join(', ')
  SEARCH_ENGINES_KEYS = SEARCH_ENGINES.keys.map{|e|"!"+e}.join(', ')
  SEARCH_ENGINES_HELP = SEARCH_ENGINES.keys.map{|e|"!"+e+" [search]"}.join(', ')

  Dir[File.expand_path "plugins/*.rb"].each{|f| require_relative(f)}
  BotpopPlugins::constants.each do |youknowwhatimeanplug|
    prepend BotpopPlugins::const_get(youknowwhatimeanplug)
  end

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

      def exec_search m
        msg = get_msg m
        url = SEARCH_ENGINES[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
        url = url.gsub('___MSG___', msg)
        m.reply url
      end

      on :message, /\!(#{SEARCH_ENGINES.keys.join('|')}) .+/ do |m| exec_search m end
      on :message, /!troll .+/ do |m| exec_troll m end
      on :message, "!version" do |m| exec_version m end
      on :message, "!code" do |m| exec_code m end
      on :message, "!intra" do |m| exec_intra m end
      on :message, "!intra on" do |m| exec_intra_on m end
      on :message, "!intra off" do |m| exec_intra_off m end
      on :message, "!ping" do |m| exec_ping m end
      on :message, /!ping #doTARGETend\Z/ do |m| exec_ping_target m end
      on :message, /!dos #doTARGETend\Z/ do |m| exec_dos m end
      on :message, /!fok #doTARGETend\Z/ do |m| exec_fok m end
      on :message, /!trace #doTARGETend\Z/ do |m| exec_trace m end
      on :message, /!poke #doTARGETend\Z/ do |m| exec_poke m end
      on :message, "!cmds" do |m| exec_help m end
      on :message, "!help" do |m| exec_help m end

    end
  end

end

if __FILE__ == $0
  Botpop.new(ARGV).start
end
