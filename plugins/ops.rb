#encoding: utf-8

class Ops < Botpop::Plugin
  include Cinch::Plugin

  match(/!op/, use_prefix: false, method: :exec_op)
  match(/!op (.+)/, use_prefix: false, method: :exec_op_other)
  match(/!deop/, use_prefix: false, method: :exec_deop)
  match(/!deop (.+)/, use_prefix: false, method: :exec_deop_other)
  match(/!v/, use_prefix: false, method: :exec_voice)
  match(/!v (.+)/, use_prefix: false, method: :exec_voice_other)
  match(/!dv/, use_prefix: false, method: :exec_devoice)
  match(/!dv (.+)/, use_prefix: false, method: :exec_devoice_other)

  HELP = ["!op <nickname>", "!deop <nickname>"]
  ENABLED = config['enable'].nil? ? true : config['enable']
  CONFIG = config

  def exec_op m
    m.channel.op(m.user)
  end

  def exec_op_other m, other
    m.channel.op(other)
  end

  def exec_deop m
    m.channel.deop(m.user)
  end

  def exec_deop_other m, other
    m.channel.deop(other)
  end

  def exec_voice m
    m.channel.voice(m.user)
  end

  def exec_voice_other m, other
    m.channel.voice(other)
  end

  def exec_devoice m
    m.channel.devoice(m.user)
  end

  def exec_devoice_other m, other
    m.channel.devoice(other)
  end

end
