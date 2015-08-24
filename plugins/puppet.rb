class Puppet < Botpop::Plugin
  include Cinch::Plugin

  match(/^!pm (\#*\w+) (.*)/, use_prefix: false, method: :send_privmsg)
  match(/^!join (\#\w+)/, use_prefix: false, method: :join)
  match(/^!part (\#\w+)/, use_prefix: false, method: :part)

  HELP = ["!pm <#chat/nick> <message>", "!join <#chan>", "!part <#chan>"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def send_privmsg m, what, message
    if what.match(/^\#.+/)
      send_privmsg_to_channel(what, message)
    else
      send_privmsg_to_user(what, message)
    end
  end

  def join m, chan
    Channel(chan).join
  end

  def part m, chan
    Channel(chan).part
  end

  private
  def send_privmsg_to_channel chan, msg
    Channel(chan).send(msg)
  end

  def send_privmsg_to_user user, msg
    User(user).send(msg)
  end
  public

end
