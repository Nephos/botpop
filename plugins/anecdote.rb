require 'nokogiri'
require 'net/http'

class Anecdote < Botpop::Plugin
  include Cinch::Plugin

  match(/!a(necdote)? (.+)/, use_prefix: false, method: :exec_new)

  HELP = ["!anecdote <...>"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def exec_new m, _, s
    s.downcase!
    f = I18n.transliterate(s)[0]
    x = "Après je vous propose "
    x += (%w(a e i o u y).include?(f) ? "d'" : "de ") if not s.match(/^(d'|de ).+/)
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
    begin
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
    rescue => _err
    end
    m.reply meme ? meme : "Achtung ! ACHTUUUUNG !!!"
  end

end
