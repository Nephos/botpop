class IAmAlive < Botpop::Plugin
  include Cinch::Plugin

  match(/^[^!].*/, use_prefix: false, method: :register_entry)
  match(/^[^!].*/, use_prefix: false, method: :react_on_entry)
  CONFIG = config(:safe => true)
  ENABLED = CONFIG['enable'] || false
  DATABASE_FILE = (Dir.pwd + "/plugins/iamalive/" + (CONFIG['database'] || "db.sqlite3"))

  if ENABLED
    require 'sequel'
    DB = Sequel.sqlite(DATABASE_FILE)
    require_relative 'iamalive/entry'
  end

  def register_entry m
    Entry.create(user: m.user.to_s, message: m.message)
  end

  def react_on_entry m
  end

end
