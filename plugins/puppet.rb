class Puppet < Botpop::Plugin
  include Cinch::Plugin

  match(/^!pm (\#*\w+) (.*)/, use_prefix: false, method: :send_privmsg)
  match(/^!join (\#\w+)/, use_prefix: false, method: :join)
  match(/^!part (\#\w+)/, use_prefix: false, method: :part)
  match(/^!let (\w+) (.+)/, use_prefix: false, method: :let)
  match(/^!read/, use_prefix: false, method: :read)

  HELP = ["!pm <#chat/nick> <message>", "!join <#chan>", "!part <#chan>", "!let <to> msg", "!read"]
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

  def let m, nick, msg
    # insert new message in database
    Base::DB[:messages].insert(author: m.user.nick,
                               dest: nick,
                               content: msg,
                               created_at: Time.now,
                               read_at: nil)
    User(nick).monitor
  end

  def read m
    msg = Base::DB[:messages].where(dest: m.user.nick).where(read_at: nil).first
    if msg.nil?
      m.reply "No message."
      return
    end
    Base::DB[:messages].where(id: msg[:id]).update(read_at: Time.now)
    m.reply "##{msg[:id]}(#{msg[:created_at]}) #{msg[:author]} > #{msg[:content]}"
  end

  listen_to :join,  method: :bip_on_join

  def bip_on_join m
    nb = Base::DB[:messages].where(dest: m.user.nick, read_at: nil).count
    m.reply "#{m.user.nick}: You have #{nb} message unread." unless nb.zero?
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
