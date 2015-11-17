require 'nokogiri'
require 'net/http'
require "i18n"

class Anecdote < Botpop::Plugin
  include Cinch::Plugin

  match(/!a(necdote)? (.+)/, use_prefix: false, method: :exec_new)

  HELP = ["!anecdote <...>"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def exec_new m, _, s
    s.downcase!
    I18n.config.available_locales = [:en, :fr]
    f = I18n.transliterate(s)[0]
    x = "Après je vous propose d"
    x += (%w(a e i o u y).include?(f) ? "'" : "e ") if not s[0..1].match(/d['e] /)
    s = x + s
    url = URI.parse 'http://memegenerator.net/create/instance'
    post_data = {
      'imageID' => 14185932,
      'generatorID' => 5374051,
      'watermark1' => 1,
      'uploadtoImgur' => 'true',
      'text0' => s,
      'text1' => "Ca fera une petite anecdote !!",
    }
    meme = nil
    Net::HTTP.start url.host do |http|
      post = Net::HTTP::Post.new url.path
      post.set_form_data post_data
      res = http.request post
      location = res['Location']
      redirect = url + location
      get = Net::HTTP::Get.new redirect.request_uri
      res = http.request get
      doc = Nokogiri.HTML res.body
      meme = doc.css("meta")[7]['content']
    end
    m.reply meme ? meme : "Achtung ! ACHTUUUUNG !!!"
  end

end
