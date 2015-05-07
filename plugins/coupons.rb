#encoding: utf-8

module BotpopPlugins

  CONFIG = YAML.load_file('plugins/coupon_login.yml')['creditentials']

  USER = CONFIG['username']
  PASS = CONFIG['password']
  def self.exec_coupon m
    coupon = m.params[1..-1].join(' ').gsub(/(coupon:)/, '').split.first
    `curl https://api.pathwar.net/organization-coupons/#{coupon}  -u '#{USER}:#{PASS}' -X GET >> /tmp/log_api_pathwar`
    m.reply "#{coupon} validated"
  end

end
