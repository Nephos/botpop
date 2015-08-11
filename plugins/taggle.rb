#encoding: utf-8

class Taggle < BotpopPlugin
  include Cinch::Plugin

  match(/!tg (.+)/, use_prefix: false, method: :exec_tg)

  HELP = ["!tg [nick]"]
  CONFIG = Botpop::CONFIG['taggle'] || {} || raise(MissingConfigurationZone, self.to_s)
  ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable'] rescue true
  NTIMES = CONFIG['ntimes'] || 10
  WAIT = CONFIG['wait'] || 0.3

  def exec_tg c, m, who
    @@tg_lock ||= Mutex.new
    @@tg_lock.lock
    begin
      NTIMES.times do
        c.User(who).send("tg #{who}")
        sleep WAIT
      end
    ensure
      @@tg_lock.unlock
    end
  end

end
