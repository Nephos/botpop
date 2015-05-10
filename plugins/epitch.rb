#encoding: utf-8

module BotpopPlugins
  module Epitech
    NAME = self.to_s.split(':').last

    MATCH = lambda do |parent, plugin|
      parent.on :message, /!admin/ do |m| plugin.exec_admin m end
      parent.on :message, /!bocal/ do |m| plugin.exec_bocal m end
      parent.on :message, /!astek/ do |m| plugin.exec_astek m end
    end
    HELP = ["!admin", "!bocal"]
    CONFIG = Botpop::CONFIG['epitech'] || raise(MissingConfigurationZone, NAME)
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']
    ASTEKS = CONFIG['asteks'] || []

    def self.exec_admin m
      m.reply "Afk"
    end

    def self.exec_bocal m
      m.reply "Bataaaaaaaards !!"
    end

    def self.exec_astek m
      m.reply ASTEKS.shuffle.first
    end

  end
end
