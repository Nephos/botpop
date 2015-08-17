# coding: utf-8

class Poilo < Botpop::Plugin
  include Cinch::Plugin

  match(/^[^!].+/, use_prefix: false, method: :exec_poilo)

  ENABLED = config['enable'].nil? ? false : config['enable']
  SYLLABE = %w(a i o u y oi eau au ou an eu)
  CONFIG = config

  def exec_poilo m
    word = m.message.split.last
    syl = word.split(/[^aeiouy]/).last
    m.reply "poil au " + CONFIG["list"][syl] if not syl.nil?
  end
end
