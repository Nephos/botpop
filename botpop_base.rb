#encoding: utf-8

module BotpopPlugins
  module Base

    VERSION = IO.read('version')

    SEARCH_ENGINES = YAML.load_file(Arguments.new(ARGV).config_file)["search_engines"]
    SEARCH_ENGINES_VALUES = SEARCH_ENGINES.values.map{|e|"!"+e}.join(', ')
    SEARCH_ENGINES_KEYS = SEARCH_ENGINES.keys.map{|e|"!"+e}.join(', ')
    SEARCH_ENGINES_HELP = SEARCH_ENGINES.keys.map{|e|"!"+e+" [search]"}.join(', ')
    TARGET = /[[:alnum:]_\-\.]+/

    def get_msg m
      URI.encode(m.params[1..-1].join(' ').gsub(/\![^ ]+ /, ''))
    end

    def get_ip m
      m.params[1..-1].join(' ').gsub(/\![^ ]+ /, '').gsub(/[^[:alnum:]\-\_\.]/, '')
    end

    def help m
      m.reply "!cmds, !help, !version, !code, !dos [ip], !fok [nick], !ping, !ping [ip], !trace [ip], !poke [nick], !troll [msg], !intra, !intra [on/off], #{SEARCH_ENGINES_HELP}"
    end

    def exec_version m
      m.reply VERSION
    end

    def exec_code m
      m.reply "https://github.com/pouleta/botpop"
    end

    def exec_help
      help m
    end

  end
end
