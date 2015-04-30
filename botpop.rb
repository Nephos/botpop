#!/usr/bin/env ruby
#encoding: utf-8

require 'cinch'
require 'uri'
#require 'pry'

VERSION = "0.1"

SEARCH_ENGINES = {
  "ddg" => "https://duckduckgo.com/?q=___MSG___",
  "yt" => "https://www.youtube.com/results?search_query=___MSG___",
  "yp" => "https://www.youporn.com/search/?query=___MSG___",
  "gh" => "https://github.com/search?q=___MSG___&type=Code&utf8=%E2%9C%93",
  "w" => "https://en.wikipedia.org/wiki/Special:Search?&go=Go&search=___MSG___",
  "tek" => "https://intra.epitech.eu/user/___MSG___",
}
SEARCH_ENGINES_VALUES = SEARCH_ENGINES.values.map{|e|"!"+e}.join(', ')

def get_msg m
  URI.encode(m.params[1..-1].join(' ').gsub(/\![^ ]+ /, ''))
end

def help m
  m.reply "!help, !cmds, !status, !version, !ddos, !code, #{SEARCH_ENGINES_VALUES}"
end

bot = Cinch::Bot.new do
  configure do |c|
    if ARGV[0] == "pathwar"
      c.server = "irc.pathwar.net"
      c.channels = ["#pathwar-fr"]
    else
      c.server = "irc.freenode.org"
      c.port = 7000
      c.channels = ["#equilibre"]
      c.ssl.use = true
    end

    c.user = "cotcot"
    c.nick = "cotcot"
  end

  on :message, "!status" do |m|
    hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
    url = "http://www.fuck-you-internet.com/delivery.php?text=#{hours}h%20apr%C3%A8s%20le%20d%C3%A9but%20du%20pathwar"
    m.reply url
  end

  on :message, /\!(#{SEARCH_ENGINES.keys.join('|')}) .+/ do |m|
    msg = get_msg m
    url = SEARCH_ENGINES[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
    url.gsub!('___MSG___', msg)
    m.reply url
  end

  on :message, "!version" do |m|
    m.reply VERSION
  end

  on :message, /!ddos (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ do |m|
    ip = get_msg m
    m.reply "I am not allowed to ddos #{ip}"
  end

  on :message, "!code" do |m|
    m.reply "https://github.com/pouleta/botpop"
  end

  on :message, "!cmds" do |m|
    help m
  end

  on :message, "!help" do |m|
    help m
  end

end

bot.start
