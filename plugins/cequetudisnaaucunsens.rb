class CeQueTuDisNAAucunSens < Botpop::Plugin
  include Cinch::Plugin

  match(/!?wha+t/, use_prefix: false, method: :say_random)

  HELP = ["!what"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def say_random m
    m.reply %w(ce que tu dis n'a aucun sens).shuffle.join(' ')
  end

end
