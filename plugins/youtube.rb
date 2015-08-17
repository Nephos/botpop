require 'mechanize'

class Youtube < Botpop::Plugin
  include Cinch::Plugin

  match(/!yt (.+)/, use_prefix: false, method: :find_youtube_video)

  HELP = ["!yt title"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  private
  def search_url(title)
    CONFIG['search_url'].gsub('___MSG___', title)
  end
  def reduce_url(url)
    CONFIG['reduce_url'].gsub('___ID___', url.gsub(/^(.+)(v=)(\w+)$/, '\3'))
  end
  def display(result)
    CONFIG['display']
      .gsub('___TITLE___', result[:title])
      .gsub('___URL___', reduce_url(result[:url]))
  end
  public

  def find_youtube_video m, title
    e = Mechanize.new
    binding.pry
    e.get(search_url(title))
    result = {
      title: e.page.at(".item-section li").at('h3').text,
      url: e.page.at(".item-section li").at('a')[:href],
    }
    m.reply display(result)
  end

end
