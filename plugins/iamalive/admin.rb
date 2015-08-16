require 'sequel'

class IAmAlive

  class Admin < Sequel::Model
    set_dataset DB[:admins]
  end

end
