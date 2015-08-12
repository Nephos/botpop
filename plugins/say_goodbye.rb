#encoding: utf-8

class SayGoodBye < Botpop::Plugin
  include Cinch::Plugin

  match(/^!sg [\w\-\.].+/, use_prefix: false, method: :exec_sg)

  HELP = ["!sg src_name"]
  ENABLED = config['enable'].nil? ? true : config['enable']

  def exec_sg m
    arg = m.message.split.last
    m.reply config[arg].shuffle.first
  end

end
