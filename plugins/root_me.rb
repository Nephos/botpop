class RootMe < Botpop::Plugin
  include Cinch::Plugin

  FloatRegexp = "\d+(\.\d+)?"
  match(/!ep1 (\w+)/, use_prefix: false, method: :start_ep1)
  match(/^(#{FloatRegexp}) ?\/ ?(#{FloatRegexp})$/, use_prefix: false, method: :play_ep1)
  match(/^(\d+) ?\/ ?(\d+)$/, use_prefix: false, method: :play_ep1)

  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def start_ep1 m, botname
    bot = User(botname)
    bot.send "!ep1"
  end

  def play_ep1 m, n1, n2
    r = n1.to_f**(0.5) * n2.to_f
    str = "!ep1 -rep #{r.round 2}"
    puts str
    m.reply str
    # response will be logged by the bot, check the log
  end

end
