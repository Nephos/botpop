#encoding: utf-8

class Searchable < Botpop::Plugin
  include Cinch::Plugin

  ENABLED = config['enable'].nil? ? true : config['enable']

  VALUES = config.values.map{|e|"!"+e}.join(', ')
  KEYS = config.keys.map{|e|"!"+e}.join(', ')
  HELP = config.keys.map{|e|"!"+e+" [search]"}
  CONFIG = config
  match(/\!(#{config.keys.join('|')}) .+/, use_prefix: false, method: :exec_search)

  def exec_search m
    msg = Botpop::Builtins.get_msg m
    url = CONFIG[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
    url = url.gsub('___MSG___', msg)
    m.reply url
  end

end
