require 'sequel'

class User < Sequel::Model

  def is_admin?
    self.admin
  end

  def add_group
  end

  def del_group
  end

  def belongs_to? group
    self.groups.split(',').include? group
  end

  set_dataset Base::DB[:users]

end
