#encoding: utf-8

# module BotpopPlugins
#   module Searchable

#     SEARCH_ENGINES = YAML.load_file(Arguments.new(ARGV).config_file)["search_engines"]
#     SEARCH_ENGINES_VALUES = SEARCH_ENGINES.values.map{|e|"!"+e}.join(', ')
#     SEARCH_ENGINES_KEYS = SEARCH_ENGINES.keys.map{|e|"!"+e}.join(', ')
#     SEARCH_ENGINES_HELP = SEARCH_ENGINES.keys.map{|e|"!"+e+" [search]"}.join(', ')

#     def exec_search m
#       msg = get_msg m
#       url = SEARCH_ENGINES[m.params[1..-1].join(' ').gsub(/\!([^ ]+) .+/, '\1')]
#       url = url.gsub('___MSG___', msg)
#       m.reply url
#     end

#   end
# end
