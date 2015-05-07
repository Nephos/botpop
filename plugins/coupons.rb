#encoding: utf-8

require 'uri'
require 'net/http'
require 'json'

module BotpopPlugins

  COUPON_CONFIG = YAML.load_file('plugins/coupon_login.yml')['creditentials']
  COUPON_USER = COUPON_CONFIG['username']
  COUPON_PASS = COUPON_CONFIG['password']
  COUPON_ORGA = COUPON_CONFIG['organisation']
  COUPON_APIU = COUPON_CONFIG['api_coupon_url']
  COUPON_URL = URI(COUPON_APIU)

  def self.exec_coupon m
    coupon = m.params[1..-1].join(' ').gsub(/(coupon:)/, '').split.first
    coupon = coupon.gsub(/[^A-z0-9\.\-_]/, '') # secure a little
    begin
      http = Net::HTTP.new(COUPON_URL.host, COUPON_URL.port)
      http.use_ssl = true
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(COUPON_URL)
      request.add_field('Content-Type', 'application/json')
      request.basic_auth COUPON_USER, COUPON_PASS
      request.body = {'coupon' => coupon, 'organisation' => COUPON_ORGA}.to_json
      response = http.request(request)
      # `curl https://api.pathwar.net/organization-coupons/#{coupon} -u '#{USER}:#{PASS}' -X GET`
      m.reply "#{coupon} " + (response.code == '200' ? 'validated' : "failed with #{response.code}")
    rescue => e
      m.reply "#{coupon} buggy"
    end
  end

end
