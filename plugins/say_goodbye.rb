#encoding: utf-8

module BotpopPlugins
  module SayGoodByePlugin
    NAME = self.to_s.split(':').last

    MATCH = lambda do |parent, plugin|
      parent.on :message, /!sg [\w\d_\-\.].+/ do |m| plugin.exec_sg m end
    end
    HELP = ["!sg src_name"]
    CONFIG = Botpop::CONFIG['say_goodbye'] || raise(MissingConfigurationZone, NAME)
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

    def self.exec_sg m
      arg = m.message.split.last
      m.reply CONFIG[arg].shuffle.first
    end

  end
end
