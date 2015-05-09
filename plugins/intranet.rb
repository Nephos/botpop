#encoding: utf-8

module BotpopPlugins
  module Intranet

    MATCH = lambda do |parent, plugin|
      parent.on :message, "!intra" do |m| plugin.exec_intra m end
      parent.on :message, "!intra on" do |m| plugin.exec_intra_on m end
      parent.on :message, "!intra off" do |m| plugin.exec_intra_off m end
    end
    HELP = ["!intra <on, off>"]
    CONFIG = Botpop::CONFIG['intranet'] || raise(MissingConfigurationZone, 'intranet')
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

    def self.exec_intra m
      m.reply Builtin.intra_state rescue m.reply "I'm buggy. Sorry"
    end

    INTRA_PING_SLEEP = 30
    def self.exec_intra_on m
      @intra ||= Mutex.new
      if @intra.try_lock
        @intra_on = true
        m.reply "INTRANET SPY ON"
        while @intra_on
          m.reply Builtin.intra_state rescue return @intra.unlock
          sleep INTRA_PING_SLEEP
        end
        @intra.unlock
      else
        m.reply "INTRA SPY ALREADY ON"
      end
    end

    def self.exec_intra_off m
      m.reply @intra_on ? "INTRA SPY OFF" : "INTRA SPY ALREADY OFF"
      @intra_on = false
    end

  end
end
