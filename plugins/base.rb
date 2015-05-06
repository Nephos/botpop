#encoding: utf-8

module BotpopPlugins
  module Base

    VERSION = IO.read('version')
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

    def exec_troll m
      # hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
      s = get_msg m
      url = "http://www.fuck-you-internet.com/delivery.php?text=#{s}"
      m.reply url
    end

  end
end
