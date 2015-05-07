#encoding: utf-8

require 'uri'
require 'net/http'
require 'json'

module BotpopPlugins
  module Coupons

    MATCH = lambda do |parent, plugin|
      parent.on :message, /coupon: .+/ do |m| plugin.exec_coupon m end
    end

    CONFIG = YAML.load_file('plugins/coupon_login.yml')['creditentials']
    USER = CONFIG['username']
    PASS = CONFIG['password']
    ORGA = CONFIG['organisation']
    APIU = CONFIG['api_coupon_url']
    URL = URI(APIU)

    def self.exec_coupon m
      @lockcoupon ||= Mutex.new
      coupon = m.params[1..-1].join(' ').gsub(/(coupon:)/, '').split.first
      coupon = coupon.gsub(/[^A-z0-9\.\-_]/, '') # secure a little
      begin
        http = Net::HTTP.new(URL.host, URL.port)
        http.use_ssl = true
        # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(URL)
        request.add_field('Content-Type', 'application/json')
        request.basic_auth USER, PASS
        request.body = {'coupon' => coupon, 'organization' => ORGA}.to_json
        response = http.request(request)
        # `curl https://api.pathwar.net/organization-coupons/#{coupon} -u '#{USER}:#{PASS}' -X GET`
        m.reply "#{coupon} " + (response.code[0] == '2' ? 'validated' : "failed with #{response.code}")
      rescue => e
        m.reply "#{coupon} buggy"
      end
      if $debug_coupons and @lockcoupon.try_lock
        binding.pry
        @lockcoupon.unlock
      end
    end

  end
end
