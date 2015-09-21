#encoding: utf-8

class Taggle < Botpop::Plugin
  include Cinch::Plugin

  match(/!tg (.+)/, use_prefix: false, method: :exec_tg)

  HELP = ["!tg [nick]"]
  CONFIG = config(safe: true) || {}
  ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']
  NTIMES = CONFIG['ntimes'] || 10
  WAIT = CONFIG['wait'] || 0.3

  def cmd_allowed? m
    return Base.cmd_allowed? m, ["tg"]
  end

  def exec_tg m, who
    return if not cmd_allowed? m
    @@tg_lock ||= Mutex.new
    @@tg_lock.lock
    begin
      NTIMES.times do
        User(who).send("tg #{who}")
        sleep WAIT
      end
    ensure
      @@tg_lock.unlock
    end
  end

end
