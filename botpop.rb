#!/usr/bin/env ruby
#encoding: utf-8

require 'cinch'
require 'uri'
require 'net/ping'
require 'pry'
require 'yaml'

require_relative 'action'
require_relative 'arguments'

# If you want, you can create your own plugins
require_relative 'botpop_base'
require_relative 'botpop_network'

class Botpop

  BotpopPlugins::constants.each{ |youknowwhatimeanplug| prepend BotpopPlugins::const_get(youknowwhatimeanplug)}

  def start
    @engine.start
  end

  def exec_troll m
    # hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
    s = get_msg m
    url = "http://www.fuck-you-internet.com/delivery.php?text=#{s}"
    m.reply url
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

      on :message, /\!(#{SEARCH_ENGINES.keys.join('|')}) .+/ do |m|
        msg = get_msg m
        url = SEARCH_ENGINES[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
        url = url.gsub('___MSG___', msg)
        m.reply url
      end

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
