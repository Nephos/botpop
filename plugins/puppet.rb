require 'date'

class Puppet < Botpop::Plugin
  include Cinch::Plugin

  match(/^!pm (\#*\w+) (.*)/, use_prefix: false, method: :send_privmsg)
  match(/^!join (\#\w+)/, use_prefix: false, method: :join)
  match(/^!part (\#\w+)/, use_prefix: false, method: :part)

  # Email handlement
  EMAIL = '[[:alnum:]\.\-_]{1,64}@[[:alnum:]\.\-_]{1,64}'
  NICK = '\w+'
  # Registration of an email address - association with authname
  match(/^!mail register (#{EMAIL})$/, use_prefix: false, method: :register)
  match(/^!mail primary (#{EMAIL})$/, use_prefix: false, method: :make_primary)
  # Send email to user through its nickname (not safe)
  match(/^!(mail )?(let|send) (#{NICK}) (.+)/, use_prefix: false, method: :let)
  # Send email to user through one of its emails (safe)
  match(/^!(mail )?(let|send) (#{EMAIL}) (.+)/, use_prefix: false, method: :let)
  # Read email (based on nickname, authname, and emails)
  match(/^!(mail )?r(ead)?$/, use_prefix: false, method: :read)

  HELP = ["!pm <#chat/nick> <message>", "!join <#chan>", "!part <#chan>", "!let <to> msg", "!read"] +
    ["!mail read", "!mail send/let <...>", "!mail register address"]
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

  def register m, email
    begin
      Base::DB[:emails].insert(authname: m.user.authname,
                               address: email,
                               created_at: Time.now.utc,
                               usage: 0)
    rescue => _
      return m.reply "Error, cannot register this email !"
    end
    return m.reply "Email #{email} registered for you, #{m.user.authname}"
  end

  def make_primary m, email
    m = get_addresses(user, address: email)
    return m.reply "No your email #{email}" if m.nil?
    get_adresses.update(primary: false)
    m.update(primary: true)
  end

  def let m, _, _, to, msg
    log "New message addressed to #{to} to send"
    # insert new message in database
    Base::DB[:messages].insert(author: m.user.nick,
                               dest: to,
                               content: msg,
                               created_at: Time.now,
                               read_at: nil)
    Base::DB[:emails].where(address: to).update('usage = usage+1')
  end

  def read m, _
    msg = get_messages(m.user).first
    if msg.nil?
      send_privmsg_to_user m.user, "No message."
      return
    end
    Base::DB[:messages].where(id: msg[:id]).update(read_at: Time.now)
    date = msg[:created_at]
    if Date.parse(Time.now.to_s) == Date.parse(date.to_s)
      date = date.strftime("%H:%M:%S")
    else
      date = date.strftime("%B, %d at %H:%M:%S")
    end
    send_privmsg_to_user m.user, "##{msg[:id]}# #{date} -- from #{msg[:author]}"
    send_privmsg_to_user m.user, msg[:content]
  end

  listen_to :join,  method: :bip_on_join

  def bip_on_join m
    nb = Base::DB[:messages].where(dest: m.user.nick, read_at: nil).count
    send_privmsg_to_user m.user, "#{m.user.nick}: You have #{nb} message unread." unless nb.zero?
  end

  private
  def send_privmsg_to_channel chan, msg
    Channel(chan).send(msg)
  end

  def send_privmsg_to_user user, msg
    User(user).send(msg)
  end

  def get_messages user
    emails = Base::DB[:emails].where(authname: user.authname).select(:address).all.map(&:values).flatten
    Base::DB[:messages].where(dest: [user.nick, user.authname] + emails).where(read_at: nil)
  end

  def get_addresses user
    Base::DB[:emails].where(authname: user.authname)
  end

end
