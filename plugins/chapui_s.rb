#encoding: utf-8

module BotpopPlugins
  module ChapuiSPlugin
    NAME = self.to_s.split(':').last

    MATCH = lambda do |parent, plugin|
      parent.on :message, /!chapui(_s)?/ do |m| plugin.exec_chapui_s m end
    end
    HELP = ["!chapui"]
    CONFIG = Botpop::CONFIG['chapui_s'] || raise(MissingConfigurationZone, NAME)
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

    def self.exec_chapui_s m
      @chapui_lock ||= Mutex.new
      @chapui_run = false

      if @chapui_lock.try_lock
        @chapui_run = true

        loop do
          m.reply "@chapui_s ? T'es là ?"
          CONFIG['sleep'].to_s.times do
            sleep 1
            if @chapui_run == false
              @chapui_lock.unlock
              return
            end
          end
        end

      else
        @chapui_run = false
      end

    end

  end
end
