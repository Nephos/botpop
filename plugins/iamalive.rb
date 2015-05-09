# encoding: utf-8

# 4.times {puts "=".yellow * 74}
# puts "THE IAMALIVE PLUGINS IN INSANE. DISABLE BY USING --plugin-disable iamalive".red
# 4.times {puts "=".yellow * 74}
# sleep 1

module BotpopPlugins
  module IAmAlive

    MATCH = lambda do |parent, plugin|
      parent.on :message, /.+/ do |m| plugin.exec_learn m end
      parent.on :message, /.+/ do |m| plugin.exec_speak m end
      parent.on :message, "!iaa clean" do |m| plugin.exec_clean m end
    end
    HELP = ["I'm learning from you"]

    CONFIG = Botpop::CONFIG['iamalive'] || raise(MissingConfigurationZone, 'iamalive')
    DATABASE_FILE = CONFIG['database_file'] || raise(MissingConfigurationEntry, 'iamalive::database_file')
    File.open(DATABASE_FILE, 'r') rescue init_database
    # DISABLED MAY BE CONFIGURED, DEFAULT IS TRUE
    ENABLED = CONFIG['enable'].nil? ? false : CONFIG['enable']

    def self.init_database
      f = File.open(DATABASE_FILE, 'w')
      f.write("learn:\n")
      f.close
    end

    def self.open_database
      begin
        @iamalive_db = YAML.load_file(DATABASE_FILE)['learn'].to_a
      rescue
        init_database
        retry
      end
    end

    # Store in a database
    def self.exec_learn m
      line = m.params[1..-1].join(' ').to_yaml.gsub("--", "  ").gsub("...\n", "")
      return if line.include?("VERSION") or line.match /\A["']?!/ or line.match(/\Ahttp/)
      f = File.open(DATABASE_FILE, 'a')
      f.write(line)
      f.close
      # m.reply "Learn: #{line}"
    end

    PROBA = 6
    def self.exec_speak m
      if Random.rand(PROBA).zero?
        open_database
        i = Random.rand(@iamalive_db.size)
        m.reply @iamalive_db[i]
      else
        # m.reply "no reply"
      end
    end

    def self.exec_clean m
      init_database
    end

  end
end
