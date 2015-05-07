#encoding: utf-8

module NetworkBase

  def self.ping(ip)
    Net::Ping::External.new(ip).ping?
  end

  def self.intra_state
    Net::Ping::External.new("intra.epitech.eu").ping? ? "Intra ok" : "Intra down"
  end

  def self.trace ip
    `tracepath '#{ip}'`.to_s.split("\n")
  end

  def self.dos_hping(ip, duration)
    `timeout #{duration} hping --flood '#{ip}' 2>&1`
  end

  def self.get_ip_from_nick m
    nick = BotpopHelper::get_ip m
    ip = m.target.users.keys.find{|u| u.nick == nick rescue nil}.host rescue nil
    return {nick: nick, ip: ip}
  end

end
