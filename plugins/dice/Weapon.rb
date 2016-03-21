require_relative 'Dice'
require_relative 'Warrior'

class Weapon
  attr_reader :from, :degats, :opt, :bonus

  def initialize from, degats, opt, bonus, attack_opt={}
    @from = from
    @bonus = from.bab.map{|e| e + bonus}
    @degats = Dice.new(degats + "+#{(from.bstr * 1.5).ceil}")
    @hands = opt[:hands] || 1
    @max = attack_opt[:max] || Float::INFINITY
  end

  def min
    @degats.min
  end

  def max
    @degats.max
  end

  def mean
    @degats.mean
  end

  def test
    @degats.test
  end

  def mean_p(ca=20.0)
    d = @degats.mean.inject(&:+)
    p(ca).map do |b|
      (b * d).round(4)
    end
  end

  def p(ca=20.0)
    @bonus.map do |b|
      ((b + from.bstr) / ca.to_f).round(4)
    end
  end

  def mean_p_total(ca=20.0)
    mean_p(ca).inject(&:+).round(4)
  end

  def to_s(ca=20)
    "mean: #{mean} * #{p(ca)} => #{mean_p(ca)} = #{mean_p_total(ca)}"
  end

end

if __FILE__ == $0
  alteration = 2
  taille = -2
  bonus = alteration + taille

  epees = []
  normal = Warrior.new 18, {bab: [7, 1]}
  epees << ["normal", Weapon.new(normal, "4d6+2", {hands: 2}, bonus)]

  rage = Warrior.new 19+4, {bab: [7, 1]}
  epees << ["rage", Weapon.new(rage, "4d6+2", {hands: 2}, bonus)]

  fren = Warrior.new 19+6, {bab: [7, 1]}
  epees << ["frenesie", Weapon.new(fren, "4d6+2", {hands: 2}, bonus)]

  ra_fr = Warrior.new 19+4+6, {bab: [7, 7, 1]}
  epees << ["rage+frenesie", Weapon.new(ra_fr, "4d6+2", {hands: 2}, bonus)]

  ra_fr_so = Warrior.new 19+6+4, {bab: [7, 7, 1]}
  epees << ["rage+frenesie+sorciere", Weapon.new(ra_fr_so, "4d6+2+5+1d6", {hands: 2}, bonus)]

  ra_fr_so_buff = Warrior.new 19+6+4+4, {bab: [7, 7, 1]}
  epees << ["rage+frenesie+sorciere+taureau+benediction", Weapon.new(ra_fr_so, "4d6+2+5+1d6", {hands: 2}, bonus+1)]

  ra_fr_so_buff_char = Warrior.new 19+6+4+4, {bab: [7, 7]}
  epees << ["rage+frenesie+sorciere+taureau+benediction+charge", Weapon.new(ra_fr_so, "4d6+2+5+1d6", {hands: 2}, bonus+1+2, {max: 2})]

  epees = Hash[epees]
  require 'pry'
  binding.pry
end
