class FrozenDice
  attr_reader :min, :max, :values, :nb, :faces

  def initialize arg
    if arg.is_a? String
      v = arg.match(/^(?<nb>\d+)d(?<faces>\d+)$/i)
      if v
        set_rolldice v
      else
        raise ArgumentError unless arg.match(/^\d+$/)
        set_value arg.to_i
      end
    elsif arg.is_a? Integer
      set_value arg
    else
      raise ArgumentError
    end
  end

  def throw
    @nb.times.map{ rand(@values) }
  end

  def test
    self.throw.inject(&:+)
  end

  def mean
    v = values.to_a
    if v.size % 2 == 0
      (v[v.size / 2 - 1] + v[v.size / 2]) * 0.5
    else
      v[v.size / 2]
    end
  end

  private
  def set_rolldice v
    @nb, @faces = v[:nb].to_i, v[:faces].to_i
    @max = @faces
    @min = 1
    @values = @min..@max
  end

  def set_value v
    @nb = 1
    @faces = v
    @min = @faces
    @max = @faces
    @values = @min..@max
  end

end

class Dice
  attr_accessor :bonus, :dices

  def initialize *arg
    @dices = []
    arg.each do |a1|
      a1.gsub!(" ", "")
      a1.split(/[+ ]/).each do |a2|
        @dices << FrozenDice.new(a2)
      end
    end
  end

  def min
    @dices.map do |dice|
      dice.min
    end
  end

  def mean
    @dices.map do |dice|
      dice.mean
    end
  end

  def max
    @dices.map do |dice|
      dice.max
    end
  end

  def throw
    @dices.map do |dice|
      dice.throw
    end
  end

  def test
    @dices.map do |dice|
      dice.test
    end.inject(&:+)
  end

end
