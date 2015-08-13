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

  CONFIG = config(:safe => true)
  ENABLED = CONFIG['enable'] || false
  DATABASE_FILE = (Dir.pwd + "/plugins/iamalive/" + (CONFIG['database'] || "db.sqlite3"))

  @@mode = :learn
  @@reactivity = config['reactivity'] || 50

  if ENABLED
    require 'sequel'
    DB = Sequel.sqlite(DATABASE_FILE)
    require_relative 'iamalive/entry'
  end

  def register_entry m
    Entry.create(user: m.user.to_s, message: m.message)
  end

  def react_on_entry m
    return if @@mode != :live
    e = Entry.where(message: m.message).to_a.map(&:id).map{|x| x+1}
    if rand(1..100) > @@reactivity
      answer_to(m, e)
    end
  end

  private
  def answer_to m, e
    a = Entry.where(id: e).to_a.shuffle.first
    if not a.nil?
      m.reply a.message
      Entry.create(user: "self", message: a.message)
    end
  end
  public

  def get_reactivity m
    m.reply "Current reactivity: #{@@reactivity}"
  end

  def set_reactivity m
    @@reactivity = m.message.split[2].to_i
  end

  def set_mode_learn m
    @@mode = :learn
  end

  def set_mode_live m
    @@mode = :live
  end

  def get_mode m
    m.reply "Current mode: #{@@mode}"
  end

  def get_stats m
    m.reply "Registred sentences: #{Entry.count}"
  end

end
