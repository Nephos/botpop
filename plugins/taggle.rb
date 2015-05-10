#encoding: utf-8

module BotpopPlugins
  module Taggle
    NAME = self.to_s.split(':').last

    MATCH = lambda do |parent, plugin|
      # Self is the callback, containing User()
      parent.on :message, /!tg (.+)/ do |m, who| plugin.exec_tg self, m, who end
    end
    HELP = ["!tg [nick]"]
    CONFIG = Botpop::CONFIG['taggle'] || {} # || raise(MissingConfigurationZone, NAME)
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable'] rescue true
    NTIMES = CONFIG['ntimes'] || 10
    WAIT = CONFIG['wait'] || 0.3

    def self.exec_tg c, m, who
      @tg_lock ||= Mutex.new
      @tg_lock.lock
      begin
        NTIMES.times do
          c.User(who).send("tg #{who}")
          sleep WAIT
        end
      ensure
        @tg_lock.unlock
      end
    end

  end
end
