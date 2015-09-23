require 'sequel'

class Point < Sequel::Model

  def before_save
    return false if super == false
    self.created_at = Time.now
  end

  set_dataset Base::DB[:points]

end
