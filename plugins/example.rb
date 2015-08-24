class MyFury < Botpop::Plugin
  include Cinch::Plugin

  match(/!whatkingofanimal.*/, use_prefix: false, method: :exec_whatkingofanimal)

  HELP = ["!whatkingofanimal", "!animallist", "!checkanimal [type]"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def exec_whatkingofanimal m
    m.reply "Die you son of a" + ["lion", "pig", "red panda"].sample + " !!"
  end

end
