require_relative 'dice/Dice'
require_relative 'dice/Weapon'
require_relative 'dice/Character'
require_relative 'dice/Warrior'

class Diceroller < Botpop::Plugin
  include Cinch::Plugin

  match(/!roll (.+)/, use_prefix: false, method: :exec_roll)

  HELP = ["!roll (d20 ...)"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  CHARACTER = Warrior.new 10, {bab: [0]}

  def exec_roll(m, roll)
    val = Weapon.new(CHARACTER, roll, {hands: 1}, 0).test
    m.reply "Roll ... '#{roll}' ... #{val}"
  end

end
