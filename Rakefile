#encoding: utf-8

require 'yaml'
CONFIG = YAML.load_file("modules_config.yml")

#require 'sequel'
#DB_BASE = Sequel.connect(CONFIG['base']['database'])

#task :default => ["x:x"]

namespace :db do
  task :install do
    # TODO: use CONFIG['base']
    `sequel -m plugins/base/migrations postgres://root:toor@localhost:5432/botpop_base`
  end
end

