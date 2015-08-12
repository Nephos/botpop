#encoding: utf-8

trap('SIGINT') {
  BotpopPlugins::Proxy.database_users_write({})
  exit
}

class Proxy < BotpopPlugin
  include Cinch::Plugin

  match("!proxy list", use_prefix: false, method: :exec_proxy_list)
  match("!proxy ip", use_prefix: false, method: :exec_proxy_ip)
  match("!proxy get", use_prefix: false, method: :exec_proxy_get)
  match("!proxy drop", use_prefix: false, method: :exec_proxy_drop)

  HELP = ["!proxy list", "!proxy ip", "!proxy get", "!proxy drop"]
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

  def username m
    Digest::SHA256.hexdigest m.user.nick
  end

  def password_rand
    File.readlines('/proc/sys/kernel/random/uuid').first.split('-').last.chomp
  end

  def database_users_reset
    File.write(PASSWD_FILE, '')
  end

  def database_users_read
    begin
      return File.readlines(PASSWD_FILE)
    rescue
      database_users_reset
      sleep 1
      retry
    end
  end

  def database_users_write users
    database_users_reset
    contents = (LOCKED_USERS + users.map{|u,p| "#{u}:#{p}"}).join("\n").chomp
    contents += "\n" if not contents.empty?
    File.write(PASSWD_FILE, contents)
  end

  def users
    users = database_users_read
    users.map!{|l| l.chomp.split(':')}
    users.map!{|u| {u[0] => u[1]}}
    users = users.reduce({}) {|h,pairs| pairs.each {|k,v| h[k] = v}; h}
    users
  end

  def remove_user nick
    users = database_users_read
    users.delete_if {|line| line =~ /\A#{nick}:.+/ }
    database_users_write users
  end

  def add_user username, password
    p = HTAuth::PasswdFile.new(PASSWD_FILE)
    p.add(username, password)
    p.save!
  end

  def user_exists? m
    users[username m]
  end

  def exec_proxy_list m
    users.keys.each_with_index do |username, i|
      m.reply "Proxy list [#{i+1}/#{users.size}/#{LIMIT_USERS}] : #{username}"
      sleep 0.1
    end
  end

  def exec_proxy_ip m
    m.reply "Proxy connexion on http://#{IP}:#{PORT}"
  end

  def exec_proxy_get m
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

  def exec_proxy_drop m
    if @@proxy_users.include?(m.user.nick) and user_exists? m
      @@proxy_users.delete(m.user.nick)
      remove_user(username(m))
      m.reply "Removed."
    else
      m.reply "No proxy registered with your nick on my jurisdiction."
    end
  end

end
