#encoding: utf-8

class Kick < Botpop::Plugin
  include Cinch::Plugin

  match(/!k (.+)/, use_prefix: false, method: :exec_kick)
  match(/!kick (.+)/, use_prefix: false, method: :exec_kick)
  match(/!k ([^|]+)\|(.+)/, use_prefix: false, method: :exec_kick_message)
  match(/!kick ([^|]+)\|(.+)/, use_prefix: false, method: :exec_kick_message)

  HELP = ["!kick nickname <message>"]
  ENABLED = config['enable'].nil? ? true : config['enable']
  CONFIG = config

  def exec_kick m, victim
    len = CONFIG["list"].length - 1
    msg = CONFIG["list"][rand(0..len)]
    m.channel.kick(victim, msg)
    m.reply "Bye bye " + victim
  end

  def exec_kick_message m, victim, reason
    m.channel.kick(victim, reason)
    m.reply "Bye bye " + victim
  end

end
