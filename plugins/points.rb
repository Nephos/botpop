#encoding: utf-8

class Points < Botpop::Plugin
  include Cinch::Plugin
  include Botpop::Plugin::Database

  match(/.*/, use_prefix: false, method: :save_last_user)
  match(/^!pstats?$/, use_prefix: false, method: :statistics)
  match(/^!pstats?u (\w+)$/, use_prefix: false, method: :statistics_for_user)
  match(/^!pstats?p (\w+)$/, use_prefix: false, method: :statistics_for_point)
  match(/^!p +(\w+)$/, use_prefix: false, method: :add_point_to_last)
  match(/^!p +(\w+) +(\w+)$/, use_prefix: false, method: :add_point_to_user)
  match(/hei(l|i)/i, use_prefix: false, method: :point_nazi)

  HELP = ["!p <type> [to]", "!pstats", "!pstatsu <nick>", "!pstatsp <point>"]
  ENABLED = config['enable'].nil? ? true : config['enable']
  CONFIG = config

  @@users = {}
  @@lock = Mutex.new

  def statistics m
    ret = Base::DB.fetch("SELECT points.type, COUNT(*) AS nb FROM points GROUP BY points.type ORDER BY nb DESC LIMIT 10;").all.map{|e| e[:type] + "(#{e[:nb]})"}.join(", ")
    # data = Base::DB.fetch("SELECT points.type, COUNT(points.*) AS nb FROM points GROUP BY points.type ORDER BY nb DESC LIMIT 10;").all
    # data.map!{|e| Base::DB.fetch("SELECT assigned_to FROM points GROUP BY type, assigned_to HAVING type = ? ORDER BY COUNT(*) DESC;", e[:type]).first.merge(e)}
    # ret = data.map{|e| e[:type] + "(#{e[:nb]}x #{e[:assigned_to]})"}.join(", ")
    m.reply "Top used: #{ret}"
  end

  def statistics_for_user m, u
    ret = Base::DB.fetch("SELECT points.type, COUNT(*) AS nb FROM points WHERE assigned_to = ? GROUP BY points.type ORDER BY COUNT(*) DESC LIMIT 10;", u.downcase).all.map{|e| e[:type] + "(#{e[:nb]})"}.join(", ")
    m.reply "User #{u} has: #{ret}"
  end

  def statistics_for_point m, p
    data = Base::DB.fetch("SELECT assigned_to, COUNT(*) AS nb FROM points GROUP BY type, assigned_to HAVING type = ? ORDER BY COUNT(*) DESC LIMIT 10;", p).all
    ret = data.map{|e| e[:assigned_to] + "(#{e[:nb]})"}.join(", ")
    m.reply "Point #{p}: #{ret}"
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
    count = add_point(m.user.nick, nick, type)
    m.reply "#{nick} has now #{count} points #{type} !"
  end

  def add_point_to_user m, type, nick
    count = add_point(m.user.nick, nick, type)
    m.reply "#{nick} has now #{count} points #{type} !"
  end

  def point_nazi m
    nick = m.user.nick
    count = add_point("self", nick, "nazi")
    m.reply "#{nick} has now #{count} points nazi !" if count % 10 == 0
  end

  private
  def add_point(by, to, type)
    to.downcase!
    Base::DB[:points].insert({assigned_by: by,
                              assigned_to: to,
                              type: type,
                              created_at: Time.now})
    count = Base::DB[:points].where(assigned_to: to, type: type).count
  end

end
