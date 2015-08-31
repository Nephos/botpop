#encoding: utf-8

class Log < Botpop::Plugin
  include Cinch::Plugin

  match /users$/, use_prefix: true, method: :exec_list_user
  match /remove .+$/, use_prefix: true, method: :exec_remove_user
  match /add .+$/, use_prefix: true, method: :exec_add_user
  match /clean$/, use_prefix: true, method: :exec_clean
  match /status$/, use_prefix: true, method: :exec_status
  match /enable$/, use_prefix: true, method: :exec_log_enable
  match /.+/, use_prefix: false, method: :exec_log

  HELP = ["!log enable", "!log add", "!log remove", "!log users", "!log clean", "!log status"]
  CONFIG = config
  ENABLED = CONFIG['enable'].nil? ? false : CONFIG['enable']
  USER_CONFIG = "plugins/log_user.yml"
  USERS = YAML.load_file(USER_CONFIG) || raise(MissingConfigurationZone, USER_CONFIG)

  @@log_user_list = USERS["list"]
  @@log_enabled = CONFIG["default_started"]

  def exec_list_user m
    m.reply @@log_user_list.join(", ")
    m.reply "no log admin" if @@log_user_list.empty?
  end

  def exec_remove_user m
    return unless is_admin? m
    m.message.gsub("!log add ", "").split(" ").each do |name|
      @@log_user_list.delete name unless USERS["list"].include?(name)
    end
  end

  def exec_add_user m
    return unless is_admin? m
    @@log_user_list += m.message.gsub("!log add ", "").split(" ")
    @@log_user_list.uniq!
  end

  def exec_log_enable m
    @@log_enabled = !@@log_enabled
    exec_status m
  end

  def exec_status m
    m.reply "Log #{@@log_enabled ? :enabled : :disabled}"
  end

  def exec_clean m
    return unless is_admin? m
    File.delete(CONFIG["file"]) rescue nil
  end

  def exec_log m
    log(m) if @@log_enabled
  end

  private
  def log m
    File.open(CONFIG["file"], 'a') {|f| f << (m.user.to_s + ": " + m.message + "\n")}
  end

  def is_admin? m
    @@log_user_list.include? m.user.to_s
  end

end
