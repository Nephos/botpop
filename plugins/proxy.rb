#encoding: utf-8

module BotpopPlugins
  module Proxy

    MATCH = lambda do |parent, plugin|
      parent.on :message, "!proxy list" do |m| plugin.exec_proxy_list m end
      parent.on :message, "!proxy ip" do |m| plugin.exec_proxy_ip m end
      parent.on :message, "!proxy get" do |m| plugin.exec_proxy_get m end
      parent.on :message, "!proxy drop" do |m| plugin.exec_proxy_drop m end
    end
    HELP = ["!proxy list", "!proxy ip",
            "!proxy get", "!proxy drop"]
    CONFIG = Botpop::CONFIG['proxy'] || raise(MissingConfigurationZone, 'proxy')
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

    if ENABLED
      require 'htauth'
      require 'digest'
    end

    LIMIT_USERS = CONFIG['limit_users'] || 1
    PASSWD_FILE = CONFIG['passwd_file'] || '/etc/squid3/passwords'
    IP = CONFIG['ip_addr'] || raise(MissingConfigurationEntry, 'ip_addr')
    PORT = CONFIG['ip_port'] || raise(MissingConfigurationEntry, 'ip_port')

    File.open(PASSWD_FILE, 'a') {}
    LOCKED_USERS = File.readlines(PASSWD_FILE)

    @@proxy_users = []

    def self.username m
      Digest::SHA256.hexdigest m.user.nick
    end

    def self.password_rand
      File.readlines('/proc/sys/kernel/random/uuid').first.split('-').last.chomp
    end

    def self.database_users_reset
      File.write(PASSWD_FILE, '')
    end

    def self.database_users_read
      begin
        return File.readlines(PASSWD_FILE)
      rescue
        database_users_reset
        sleep 1
        retry
      end
    end

    def self.database_users_write users
      database_users_reset
      contents = (LOCKED_USERS + users.map{|u,p| "#{u}:#{p}"}).join("\n")
      contents += "\n" if not contents.empty?
      File.write(PASSWD_FILE, contents)
    end

    def self.users
      users = database_users_read
      users.map!{|l| l.chomp.split(':')}
      users.map!{|u| {u[0] => u[1]}}
      users = users.reduce({}) {|h,pairs| pairs.each {|k,v| h[k] = v}; h}
      users
    end

    def self.remove_user nick
      users = database_users_read
      users.delete_if {|line| line =~ /\A#{nick}:.+/ }
      database_users_write users
    end

    def self.add_user username, password
      # users = database_users_read
      # users[username] = password_encrypt(password)
      # database_users_write users
      p = HTAuth::PasswdFile.new(PASSWD_FILE) #HTAuth::File::STDOUT_FLAG
      p.add(username, password)
      p.save!
    end

    def self.user_exists? m
      users[username m]
    end

    def self.exec_proxy_list m
      users.keys.each_with_index do |username, i|
        m.reply "Proxy list [#{i+1}/#{users.size}/#{LIMIT_USERS}] : #{username}"
        sleep 0.1
      end
    end

    def self.exec_proxy_ip m
      m.reply "Proxy connexion on http://#{IP}:#{PORT}"
    end

    def self.exec_proxy_get m
      if not user_exists? m
        password = password_rand
        @@proxy_users << m.user.nick
        add_user(username(m), password)
        m.reply "User : #{username(m)} created, password : #{password}"
      else
        if @@proxy_users.include? m.user.nick
          m.reply "You already have a proxy. Drop it before creating a new one."
        else
          m.reply "Locked nick #{m.user.nick} out of the my jurisdiction. Use an other."
        end
      end
    end

    def self.exec_proxy_drop m
      if @@proxy_users.include?(m.user.nick) and user_exists? m
        @@proxy_users.delete(m.user.nick)
        remove_user(username(m))
        m.reply "Removed."
      else
        m.reply "No proxy registered with your nick on my jurisdiction."
      end
    end

  end
end
