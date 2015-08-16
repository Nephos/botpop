#coding: utf-8

class Botpop
  class Plugin
    module Database

      def self.append_features(b)
        b.extend self
      end

      attr_accessor :db_config
      def db_connect!
        require 'sequel'
        @db = Sequel.connect(@db_config)
        @db
      end

    end
  end
end
