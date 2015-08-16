#coding: utf-8

class Botpop
  class Plugin
    module Database

      def self.append_features(b)
        b.extend self
      end

      attr_accessor :db_config
      attr_reader :db
      def db_connect!
        require 'sequel'
        @db = Sequel.connect(@db_config)
        @db
      end

    end
  end
end

class Botpop
  class Plugin
    module Database
      module Admin

        def cmd_allowed? m, verbose=true
          user = self.class.db[:admins].where(user: m.user.to_s).first
          if user.nil?
            m.reply "No authorized" if verbose
            return false
          else
            return true
          end
        end

        def user_add m, name
          return if not cmd_allowed? m and self.class.db[:admins].count > 0
          self.class.db[:admins].insert(user: name)
          m.reply "#{name} added to the iaa admins list"
        end

        def user_remove m, name
          return if not cmd_allowed? m
          self.class.db[:admins].where(user: name).delete
          m.reply "#{name || 'me'} removed from the iaa admins list"
        end

        def user_list m
          return if not cmd_allowed? m
          m.reply "iaa admins list: " + self.class.db[:admins].all.map{|h|h[:user]}.join(", ")
        end

      end
    end
  end
end
