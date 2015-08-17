class IAmAlive < Botpop::Plugin
  include Cinch::Plugin
  include Botpop::Plugin::Database
  include Botpop::Plugin::Database::Admin
  alias :'allowed?' :'cmd_allowed?'

  match(/^[^!].*/, use_prefix: false, method: :register_entry)
  match(/^[^!].*/, use_prefix: false, method: :react_on_entry)
  match(/^!iaa reac(tivity)?$/, use_prefix: false, method: :get_reactivity)
  match(/^!iaa reac(tivity)? \d{1,3}$/, use_prefix: false, method: :set_reactivity)
  match(/^!iaa learn$/, use_prefix: false, method: :set_mode_learn)
  match(/^!iaa live$/, use_prefix: false, method: :set_mode_live)
  match(/^!iaa mode$/, use_prefix: false, method: :get_mode)
  match(/^!iaa stats?$/, use_prefix: false, method: :get_stats)
  match(/^!iaa forget( (\d+ )?(.+))?/, use_prefix: false, method: :forget)
  match(/^!iaa last( \w+)?$/, use_prefix: false, method: :get_last)
  match(/^!iaa user add (\w+)$/, use_prefix: false, method: :user_add)
  match(/^!iaa user remove (\w+)$/, use_prefix: false, method: :user_remove)
  match(/^!iaa user list$/, use_prefix: false, method: :user_list)

  CONFIG = config(:safe => true)
  ENABLED = CONFIG['enable'] || false
  HELP = ["!iaa reac", "!iaa reac P", "!iaa learn", "!iaa live", "!iaa mode",
          "!iaa stats", "!iaa forget (Nx SENTENCE)", "!iaa last (nick)",
          "!iaa user [add/remove/list]"]

  @@mode = config['default_mode'].to_sym
  @@reactivity = config['reactivity'] || 50

  if ENABLED
    DB_CONFIG = self.db_config = CONFIG['database']
    DB = self.db_connect!
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
    if @@reactivity > rand(1..100)
      answer_to(m, e)
    end
  end

  private
  def answer_to m, e
    a = Entry.where(id: e).to_a.shuffle.first
    if not a.nil?
      sleep(a.message.split.size.to_f / 10)
      m.reply a.message
      @@db_lock.lock
      Entry.create(user: "self", message: a.message, channel: m.channel.to_s)
      @@db_lock.unlock
    end
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

  def forget m, arguments, nb, what
    return if not allowed? m
    if arguments.nil?
      @@db_lock.lock
      last = Entry.where(channel: m.channel.to_s, user: "self").last
      m.reply last ? "\"#{last.message}\" Forgotten" : "Nop"
      last.delete
      @@db_lock.unlock
    else
      nb = nb.to_i if not nb.nil?
      @@db_lock.lock
      nb ||= Entry.where(message: what).count
      n = Entry.where(message: what).order_by(:id).reverse.limit(nb).map(&:delete).size rescue 0
      @@db_lock.unlock
      m.reply "(#{n}x) \"#{what}\" Forgotten"
    end
  end

  def get_last m, user
    user.strip! if user
    last = Entry.where(channel: m.channel.to_s, user: (user || "self")).last
    m.reply "#{user}: #{last ? last.message : 'no message found'}"
  end

end
