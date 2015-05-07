# encoding: utf-8

module BotpopPlugins
  module Builtin

    def self.dos(ip, duration)
      `timeout #{duration} hping --flood '#{ip}' 2>&1`
    end

    def self.ping(ip)
      Net::Ping::External.new(ip).ping?
    end

    def self.intra_state
      Net::Ping::External.new("intra.epitech.eu").ping? ? "Intra ok" : "Intra down"
    end

    def self.trace ip
      `tracepath '#{ip}'`.to_s.split("\n")
    end

    def self.get_msg m
      URI.encode(m.params[1..-1].join(' ').gsub(/\![^ ]+ /, ''))
    end

    def self.get_ip m
      m.params[1..-1].join(' ').gsub(/\![^ ]+ /, '').gsub(/[^[:alnum:]\-\_\.]/, '')
    end

    def self.get_ip_from_nick m
      nick = get_ip m
      ip = m.target.users.keys.find{|u| u.nick == nick rescue nil}.host rescue nil
      return {nick: nick, ip: ip}
    end

  end
end
