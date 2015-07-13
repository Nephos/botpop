#encoding: utf-8

require 'uri'
require 'net/http'
require 'json'

module BotpopPlugins
  module Coupons

    COUPON_REGEXP = "[A-Fa-f0-9]{32}"
    MATCH = lambda do |parent, plugin|
      # parent.on :message, /coupon(.+)?: .+/ do |m| plugin.exec_coupon m end
      parent.on :message, /.*#{COUPON_REGEXP}.*/ do |m| plugin.exec_coupon_somewhere m end
    end
    # HELP = ["coupon: [...]"]
    HELP = []
    CONFIG = Botpop::CONFIG['coupons'] || raise(MissingConfigurationZone, 'coupons')
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

    if ENABLED
      SECRET_CONFIG = YAML.load_file('plugins/coupon_login.yml')['creditentials']
      USER = SECRET_CONFIG['username']
      PASS = SECRET_CONFIG['password']
      ORGA = SECRET_CONFIG['organisation']
      APIU = SECRET_CONFIG['api_coupon_url']
      URL = URI(APIU)
    end

    def self.get_coupon m
      coupon = m.params[1..-1].join(' ').gsub(/(coupon(.+)?:)/, '').split.first
      coupon = coupon.gsub(/[^A-z0-9\.\-_]/, '') # secure a little
      coupon
    end

    def self.get_coupons_somewhere m
      coupons = m.params[1..-1].join(' ').scan(/#{COUPON_REGEXP}/)
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

    def self.validate_coupon m, coupon
      begin
        response = send_coupon coupon
        valid_response = response.code[0] == '2'
        str = "#{coupon} " + (valid_response ? 'validated' : "failed (#{response.code})")
        m.reply coupon if CONFIG['display_coupons']
      rescue => e
        m.reply "#{coupon} buggy"
      end
    end

    # `curl https://api.pathwar.net/organization-coupons/#{coupon} -u '#{USER}:#{PASS}' -X GET`
    def self.exec_coupon m
      coupon = get_coupon m
      validate_coupon m, coupon
    end

    def self.exec_coupon_somewhere m
      coupons = get_coupons_somewhere m
      coupons.each do |coupon|
        validate_coupon m, coupon
      end
    end

  end
end
