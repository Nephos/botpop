#encoding: utf-8

require 'uri'
require 'net/http'
require 'json'

module BotpopPlugins
  module Coupons

    MATCH = lambda do |parent, plugin|
      parent.on :message, /coupon(.+)?: .+/ do |m| plugin.exec_coupon m end
    end
    HELP = ["coupon: [...]"]
    CONFIG = Botpop::CONFIG['coupons'] || raise(MissingConfigurationZone, 'coupons')
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

    SECRET_CONFIG = YAML.load_file('plugins/coupon_login.yml')['creditentials']
    USER = SECRET_CONFIG['username']
    PASS = SECRET_CONFIG['password']
    ORGA = SECRET_CONFIG['organisation']
    APIU = SECRET_CONFIG['api_coupon_url']
    URL = URI(APIU)

    def self.exec_coupon_debug
      if @lockcoupon.try_lock
        binding.pry rescue return @lockcoupon.unlock
        @lockcoupon.unlock
      end
    end

    def self.get_coupon m
      coupon = m.params[1..-1].join(' ').gsub(/(coupon(.+)?:)/, '').split.first
      coupon = coupon.gsub(/[^A-z0-9\.\-_]/, '') # secure a little
      coupon
    end

    def self.send_coupon coupon
      @http ||= Net::HTTP.new(URL.host, URL.port)
      @http.use_ssl = true
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(URL)
      request.add_field('Content-Type', 'application/json')
      request.basic_auth USER, PASS
      request.body = {'coupon' => coupon, 'organization' => ORGA}.to_json
      response = @http.request(request)
      @response = response
      @request = request
      response
    end

    def self.exec_coupon m
      @lockcoupon ||= Mutex.new
      coupon = get_coupon m
      begin
        response = send_coupon coupon
        # `curl https://api.pathwar.net/organization-coupons/#{coupon} -u '#{USER}:#{PASS}' -X GET`
        if $debug_display_coupons
          m.reply "#{coupon} " + (response.code[0] == '2' ? 'validated' : "failed with #{response.code}")
        end
      rescue => e
        m.reply "#{coupon} buggy"
        @err = e
        exec_coupon_debug if $debug_coupons
      end
      exec_coupon_debug if $debug_all_coupons
    end

  end
end
