#encoding: utf-8

module BotpopPlugins
  module Base

    MATCH = lambda do |parent, plugin|
      parent.on :message, /!troll .+/ do |m| plugin.exec_troll m end
      parent.on :message, "!version" do |m| plugin.exec_version m end
      parent.on :message, "!code" do |m| plugin.exec_code m end
      parent.on :message, "!cmds" do |m| plugin.exec_help m end
      parent.on :message, "!help" do |m| plugin.exec_help m end
    end

    HELP = ["!troll [msg]", "!version", "!code", "!help", "!cmds"]

    def self.help_wait_before_quit
      HELP_WAIT_DURATION.times do
        sleep 1
        @help_time += 1
      end
    end

    def self.help_get_plugins_str
      ["Plugins found : " + Botpop.plugins.size.to_s] +
        Botpop.plugins.map do |plugin|
        plugin.to_s.split(':').last + ': ' + plugin::HELP.join(', ') rescue nil
      end.compact
    end

    HELP_WAIT_DURATION = 120
    def self.help m
      @help_lock ||= Mutex.new
      if @help_lock.try_lock
        @help_time = 0
        help_get_plugins_str().each{|str| m.reply str} # display
        help_wait_before_quit rescue nil
        @help_lock.unlock
      else
        m.reply "Help already sent #{@help_time} seconds ago. Wait #{HELP_WAIT_DURATION - @help_time} seconds more."
      end
    end

    def self.exec_version m
      m.reply Botpop::VERSION
    end

    def self.exec_code m
      m.reply "https://github.com/pouleta/botpop"
    end

    def self.exec_help m
      help m
    end

    def self.exec_troll m
      # hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
      s = get_msg m
      url = "http://www.fuck-you-internet.com/delivery.php?text=#{s}"
      m.reply url
    end

  end
end
