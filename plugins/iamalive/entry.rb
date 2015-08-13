require 'sequel'

class IAmAlive

  class Entry < Sequel::Model
    def before_create
      self.created_at ||= Time.now
      super
    end
  end

end
