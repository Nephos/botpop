#encoding: utf-8

module BotpopPlugins
  module Searchabe

    MATCH = lambda do |parent, plugin|
      parent.on :message, /\!(#{SEARCH_ENGINES.keys.join('|')}) .+/ do |m| plugin.exec_search m end
    end

    SEARCH_ENGINES = Botpop::CONFIG["search_engines"]
    SEARCH_ENGINES_VALUES = SEARCH_ENGINES.values.map{|e|"!"+e}.join(', ')
    SEARCH_ENGINES_KEYS = SEARCH_ENGINES.keys.map{|e|"!"+e}.join(', ')
    SEARCH_ENGINES_HELP = SEARCH_ENGINES.keys.map{|e|"!"+e+" [search]"}.join(', ')

    def self.exec_search m
      msg = Builtin.get_msg m
      url = SEARCH_ENGINES[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
      url = url.gsub('___MSG___', msg)
      m.reply url
    end

  end
end
