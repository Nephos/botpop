#encoding: utf-8

class Points < Botpop::Plugin
  include Cinch::Plugin
  include Botpop::Plugin::Database

  match(/.*/, use_prefix: false, method: :save_last_user)
  match(/^!p-stats$/, use_prefix: false, method: :statistics)
  match(/^!p-stats (\w+)$/, use_prefix: false, method: :statistics_for)
  match(/^!p +(\w+)$/, use_prefix: false, method: :add_point_to_last)
  match(/^!p +(\w+) +(\w+)$/, use_prefix: false, method: :add_point_to_user)

  HELP = ["!p <type> [to]", "!p-stats [user]"]
  ENABLED = config['enable'].nil? ? true : config['enable']
  CONFIG = config

  @@users = {}
  @@lock = Mutex.new

  def statistics m
    ret = Base::DB.fetch("SELECT points.type, COUNT(points.*) AS nb FROM points GROUP BY points.type ORDER BY nb DESC LIMIT 10;").all.map{|e| e[:type] + "(#{e[:nb]})"}.join(", ")
    m.reply "Top used: #{ret}"
  end

  def statistics_for m, u
    ret = Base::DB.fetch("SELECT points.type, COUNT(points.*) AS nb FROM points WHERE assigned_to = ? GROUP BY points.type", u.downcase).all.map{|e| e[:type] + "(#{e[:nb]})"}.join(", ")
    m.reply "User #{u} has: #{ret}"
  end

  def save_last_user m
    return if m.message.match(/^!p .+$/)
    @@lock.lock
    @@users[m.channel.to_s] = m.user.nick
    @@lock.unlock
  end

  def add_point_to_last m, type
    return if @@users[m.channel.to_s].nil?
    nick = @@users[m.channel.to_s]
    Base::DB[:points].insert({assigned_by: m.user.nick, assigned_to: nick.downcase, type: type})
    count = Base::DB[:points].where(assigned_to: nick.downcase, type: type).count
    m.reply "User #{nick} has now #{count} points #{type} !"
  end

  def add_point_to_user m, type, nick
    Base::DB[:points].insert({assigned_by: m.user.nick, assigned_to: nick.downcase, type: type})
    count = Base::DB[:points].where(assigned_to: nick.downcase, type: type).count
    m.reply "User #{nick} has now #{count} points #{type} !"
  end

end
