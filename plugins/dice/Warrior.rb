require_relative 'Character'

class Warrior < Character

  def initialize str, *arg
    super(str, 10, 10, 10, 10, 10, *arg)
  end

  def str; carac[:str]; end
  def bstr; (str - 10) / 2; end

end
