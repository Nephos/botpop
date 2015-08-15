class IAmAlive < Botpop::Plugin
  include Cinch::Plugin

  match(/^[^!].*/, use_prefix: false, method: :register_entry)
  match(/^[^!].*/, use_prefix: false, method: :react_on_entry)
  match(/^!iaa reac(tivity)?$/, use_prefix: false, method: :get_reactivity)
  match(/^!iaa reac(tivity)? \d{1,3}$/, use_prefix: false, method: :set_reactivity)
  match(/^!iaa learn$/, use_prefix: false, method: :set_mode_learn)
  match(/^!iaa live$/, use_prefix: false, method: :set_mode_live)
  match(/^!iaa mode$/, use_prefix: false, method: :get_mode)
  match(/^!iaa stats?$/, use_prefix: false, method: :get_stats)
  match(/^!iaa forget (.+)/, use_prefix: false, method: :forget)
  match(/^!iaa user add (\w+)$/, use_prefix: false, method: :user_add)
  match(/^!iaa user remove (\w+)$/, use_prefix: false, method: :user_remove)
  match(/^!iaa user list$/, use_prefix: false, method: :user_list)

  CONFIG = config(:safe => true)
  ENABLED = CONFIG['enable'] || false
  SQLITE_BASE = Dir.pwd + "/plugins/iamalive/"
  HELP = ["!iaa reac", "!iaa reac P", "!iaa learn", "!iaa live", "!iaa mode", "!iaa stats", "!iaa user [add/remove/list]"]

  @@mode = config['default_mode'].to_sym
  @@reactivity = config['reactivity'] || 50

  if ENABLED
    require 'sequel'
    if CONFIG['database']['postgres']
      CONFIG_DB = CONFIG['database']['postgres']
      DB = Sequel.connect({"adapter" => "postgres"}.merge(CONFIG_DB))
    elsif CONFIG['database']['sqlite']
      CONFIG_DB = CONFIG['database']['sqlite']
      DB = Sequel.sqlite(SQLITE_BASE + CONFIG_DB['file'])
    end
    require_relative 'iamalive/entry'
    require_relative 'iamalive/admin'
    @@db_lock = Mutex.new
  end

  def register_entry m
    @@db_lock.lock
    Entry.create(user: m.user.to_s, message: m.message, channel: m.channel.to_s)
    @@db_lock.unlock
    forget_older! if rand(1..100) == 100
  end

  def react_on_entry m
    return if @@mode != :live
    @@db_lock.lock
    e = Entry.where(message: m.message).to_a.map(&:id).map{|x| x+1}
    @@db_lock.unlock
    if rand(1..100) > @@reactivity
      answer_to(m, e)
    end
  end

  private
  def answer_to m, e
    a = Entry.where(id: e).to_a.shuffle.first
    if not a.nil?
      sleep(rand(0..20).to_f/10)
      m.reply a.message
      @@db_lock.lock
      Entry.create(user: "self", message: a.message, channel: m.channel.to_s)
      @@db_lock.unlock
    end
  end

  def allowed?(m)
    Admin.find(user: m.user.to_s) || (m.reply "Not allowed"; return nil)
  end

  def forget_older!
    log "Forget the older entry"
    @@db_lock.lock
    Entry.first.delete
    @@db_lock.unlock
  end
  public

  def get_reactivity m
    m.reply "Current reactivity: #{@@reactivity}"
  end

  def set_reactivity m
    return if not allowed? m
    @@reactivity = m.message.split[2].to_i
  end

  def set_mode_learn m
    return if not allowed? m
    @@mode = :learn
  end

  def set_mode_live m
    return if not allowed? m
    @@mode = :live
  end

  def get_mode m
    m.reply "Current mode: #{@@mode}"
  end

  def get_stats m
    m.reply "Registered sentences: #{Entry.count}"
  end

  def forget m, what
    return if not allowed? m
    @@db_lock.lock
    n = Entry.where(message: what).delete
    m.reply "Removed (#{n}x) \"#{what}\""
  end

  def user_add m, name
    return if not allowed? m and Admin.count > 0
    Admin.create(user: name)
    m.reply "#{name} added to the iaa admins list"
  end

  def user_remove m, name
    return if not allowed? m
    Admin.where(user: name).delete
    m.reply "#{name} removed from the iaa admins list"
  end

  def user_list m
    return if not allowed? m
    m.reply "iaa admins list: " + Admin.all.map(&:user).join(", ")
  end

end
