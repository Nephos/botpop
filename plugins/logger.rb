#encoding: utf-8

module BotpopPlugins
  module Logger
    NAME = self.to_s.split(':').last

    MATCH = lambda do |parent, plugin|
      parent.on :message, /!log users/ do |m| plugin.exec_list_user m end
      parent.on :message, /!log remove .+/ do |m| plugin.exec_remove_user m end
      parent.on :message, /!log add .+/ do |m| plugin.exec_add_user m end
      parent.on :message, /!log clean/ do |m| plugin.exec_clean m end
      parent.on :message, /!log\Z/ do |m| plugin.exec_log_enable m end
      parent.on :message, /.+/ do |m| plugin.exec_log m end
    end
    HELP = ["!log", "!log add", "!log remove", "!log users", "!log clean"]
    CONFIG = Botpop::CONFIG['logger'] || raise(MissingConfigurationZone, NAME)
    ENABLED = CONFIG['enable'].nil? ? false : CONFIG['enable']
    USER_CONFIG = "plugins/logger_user.yml"
    USERS = YAML.load_file(USER_CONFIG) || raise(MissingConfigurationZone, USER_CONFIG)

    @@logger_user_list = USERS["list"]
    @@logger_enabled = false

    def self.exec_list_user m
      m.reply @@logger_user_list.join(", ")
      m.reply "no logger admin" if @@logger_user_list.empty?
    end

    def self.exec_remove_user m
      return unless is_admin? m
      m.message.gsub("!log add ", "").split(" ").each do |name|
        @@logger_user_list.delete name unless USERS["list"].include?(name)
      end
    end

    def self.exec_add_user m
      return unless is_admin? m
      @@logger_user_list += m.message.gsub("!log add ", "").split(" ")
      @@logger_user_list.uniq!
    end

    def self.exec_log_enable m
      @@logger_enabled = !@@logger_enabled
      m.reply "Logger #{@@logger_enabled ? :enabled : :disabled}"
    end

    def self.exec_clean m
      return unless is_admin? m
      File.delete(CONFIG["file"]) rescue nil
    end

    def self.exec_log m
      return unless is_admin? m
      log(m) if @@logger_enabled
    end

    private
    def self.log m
      File.open(CONFIG["file"], 'a') {|f| f << (m.user.to_s + ": " + m.message + "\n")}
    end

    def self.is_admin? m
      @@logger_user_list.include? m.user.to_s
    end

  end
end
