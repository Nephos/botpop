#!/usr/bin/env ruby
#encoding: utf-8

require 'cinch'
require 'uri'

SEARCH_ENGINES = {
  "ddg" => "https://duckduckgo.com/?q=___MSG___",
  "yt" => "https://www.youtube.com/results?search_query=___MSG___",
  "yp" => "http://www.youporn.com/search/?query=___MSG___",
  "gh" = "https://github.com/search?q=___MSG___&type=Code&utf8=%E2%9C%93",
}

def get_msg m
  URI.encode(m.params[1..-1].join(' ').gsub(/\!.+ /, ''))
end

def help m
  m.reply "!help, !cmds, !status, !ddg, !yt, !yp"
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

  on :message, /!ddg .+/ do |m|
    msg = get_msg m
    url = "https://duckduckgo.com/?q=#{msg}"
    m.reply url
  end

  on :message, /!yt .+/ do |m|
    msg = get_msg m
    url = "https://www.youtube.com/results?search_query=#{msg}"
    m.reply url
  end

  on :message, /!yp .+/ do |m|
    msg = get_msg m
    url = "http://www.youporn.com/search/?query=#{msg}"
    m.reply url
  end

  on :message, /!gh .+/ do |m|
    msg = get_msg m
    url = "https://github.com/search?q=#{msg}&type=Code&utf8=%E2%9C%93"
    m.reply url
  end

  on :message, "!cmds" do |m|
    help m
  end

  on :message, "!help" do |m|
    help m
  end

end

bot.start
