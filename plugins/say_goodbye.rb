#encoding: utf-8

class SayGoodBye < Botpop::Plugin
  include Cinch::Plugin

  match(/^!sg [\w\-\.].+/, use_prefix: false, method: :exec_sg)

  HELP = ["!sg src_name"]
  CONFIG = Botpop::CONFIG['say_goodbye'] || raise(MissingConfigurationZone, self.name)
  ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

  def exec_sg m
    arg = m.message.split.last
    m.reply CONFIG[arg].shuffle.first
  end

end
