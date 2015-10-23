require 'sequel'

class IAmAlive

  class IAAMessage < String

    def initialize *arg
      super(*arg)
      self.strip!
    end

  end

  class Entry < Sequel::Model
    def before_create
      self.created_at ||= Time.now
      self.message.strip!
      self.message_origin = self.message
      self.message = IAAMessage.new(self.message).to_s
      super
    end
    set_dataset DB[:entries]

    def self.anwser(message)
      Entry.where('LOWER(message) = LOWER(?)', m.message.to_iaa_message).
        select(:id).all.map(&:id).map{|x| x+1}
    end

  end

end
