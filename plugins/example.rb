#encoding: utf-8

module BotpopPlugins
  module MyFuryPlugin
    NAME = self.to_s.split(':').last

    MATCH = lambda do |parent, plugin|
      parent.on :message, /!whatkingofanimal.*/ do |m| plugin.exec_whatkingofanimal m end
    end
    HELP = ["!whatkingofanimal", "!animallist", "!checkanimal [type]"]
    CONFIG = Botpop::CONFIG['example'] || raise(MissingConfigurationZone, NAME)
    ENABLED = CONFIG['enable'].nil? ? false : CONFIG['enable']

    def self.exec_whatkingofanimal m
      m.reply "Die you son of a" + ["lion", "pig", "red panda"].shuffle.first + " !!"
    end

  end
end
