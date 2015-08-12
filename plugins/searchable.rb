#encoding: utf-8

class Searchable < Botpop::Plugin
  include Cinch::Plugin

  CONFIG = Botpop::CONFIG['searchable'] || raise(MissingConfigurationZone, self.to_s)
  ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

  VALUES = CONFIG.values.map{|e|"!"+e}.join(', ')
  KEYS = CONFIG.keys.map{|e|"!"+e}.join(', ')
  HELP = CONFIG.keys.map{|e|"!"+e+" [search]"}
  match(/\!(#{CONFIG.keys.join('|')}) .+/, use_prefix: false, method: :exec_search)

  def exec_search m
    msg = BotpopBuiltins.get_msg m
    url = CONFIG[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
    url = url.gsub('___MSG___', msg)
    m.reply url
  end

end
