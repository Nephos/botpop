#encoding: utf-8

class Points < Botpop::Plugin
  include Cinch::Plugin
  # include Botpop::Plugin::Database

  match(/.*/, use_prefix: false, method: :save_last_user)
  match(/!p +(\w+)$/, use_prefix: false, method: :add_point_to_last)
  match(/!p +(\w+) +(\w+)$/, use_prefix: false, method: :add_point_to_user)

  HELP = ["!p [type] <to>"]
  ENABLED = config['enable'].nil? ? true : config['enable']
  CONFIG = config

  if ENABLED
    require_relative 'points/PointModel'
  end

  @@users = {}
  @@lock = Mutex.new

  def save_last_user m
    return if m.message.match(/^!p .+$/)
    @@lock.lock
    @@users[m.channel.to_s] = m.user.nick
    @@lock.unlock
  end

  def add_point_to_last m, type
    return if @@users[m.channel.to_s].nil?
    nick = @@users[m.channel.to_s]
    Point.create({assigned_by: m.user.nick, assigned_to: nick.downcase, type: type})
    count = Point.where(assigned_to: nick.downcase, type: type).count
    m.reply "User #{nick} has now #{count} points #{type} !"
  end

  def add_point_to_user m, type, nick
    Point.create({assigned_by: m.user.nick, assigned_to: nick.downcase, type: type})
    count = Point.where(assigned_to: nick.downcase, type: type).count
    m.reply "User #{nick} has now #{count} points #{type} !"
  end

end
