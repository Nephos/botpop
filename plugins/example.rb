class MyFury
  include Cinch::Plugin

  match(/!whatkingofanimal.*/, use_prefix: false, method: :exec_whatkingofanimal)

  HELP = ["!whatkingofanimal", "!animallist", "!checkanimal [type]"]
  CONFIG = Botpop::CONFIG['example'] || raise(MissingConfigurationZone, self.to_s)
  ENABLED = CONFIG['enable'].nil? ? false : CONFIG['enable']

  def exec_whatkingofanimal m
    m.reply "Die you son of a" + ["lion", "pig", "red panda"].shuffle.first + " !!"
  end

end

