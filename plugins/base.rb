#encoding: utf-8

module BotpopPlugins

  MATCH_BASE = lambda do |parent|
    parent.on :message, /!troll .+/ do |m| BotpopPlugins::exec_troll m end
    parent.on :message, "!version" do |m| BotpopPlugins::exec_version m end
    parent.on :message, "!code" do |m| BotpopPlugins::exec_code m end
    parent.on :message, "!cmds" do |m| BotpopPlugins::exec_help m end
    parent.on :message, "!help" do |m| BotpopPlugins::exec_help m end
  end

  def self.get_msg m
    URI.encode(m.params[1..-1].join(' ').gsub(/\![^ ]+ /, ''))
  end

  def self.get_ip m
    m.params[1..-1].join(' ').gsub(/\![^ ]+ /, '').gsub(/[^[:alnum:]\-\_\.]/, '')
  end

  # This is the most creepy and ugly method ever see
  def self.help m
    m.reply "!cmds, !help, !version, !code, !dos [ip], !fok [nick], !ping, !ping [ip], !trace [ip], !poke [nick], !troll [msg], !intra, !intra [on/off], #{Botpop::SEARCH_ENGINES_HELP}"
  end

  def self.exec_version m
    m.reply Botpop::VERSION
  end

  def self.exec_code m
    m.reply "https://github.com/pouleta/botpop"
  end

  def self.exec_help m
    help m
  end

  def self.exec_troll m
    # hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
    s = get_msg m
    url = "http://www.fuck-you-internet.com/delivery.php?text=#{s}"
    m.reply url
  end

end
