#encoding: utf-8

class Base < Botpop::Plugin
  include Cinch::Plugin

  match /^!troll .+/ , use_prefix: false, method: :exec_troll
  match "!version" , use_prefix: false, method: :exec_version
  match "!code" , use_prefix: false, method: :exec_code
  match "!cmds" , use_prefix: false, method: :exec_help
  match "!help" , use_prefix: false, method: :exec_help
  match /^!help \w+/ , use_prefix: false, method: :exec_help_plugin

  HELP = ["!troll [msg]", "!version", "!code", "!help [plugin]", "!cmds"]
  ENABLED = config['enable'].nil? ? true : config['enable']

  def help_wait_before_quit
    HELP_WAIT_DURATION.times do
      sleep 1
      @@help_time += 1
    end
  end

  def help_get_plugins_str
    ["Plugins found : " + Botpop::PLUGINS.size.to_s] +
      Botpop::PLUGINS.map do |plugin|
      plugin.to_s.split(':').last + ': ' + plugin::HELP.join(', ') rescue nil
    end.compact
  end

  HELP_WAIT_DURATION = config['help_wait_duration'] || 120
  def help m
    @@help_lock ||= Mutex.new
    if @@help_lock.try_lock
      @@help_time = 0
      help_get_plugins_str().each{|str| m.reply str} # display
      help_wait_before_quit rescue nil
      @@help_lock.unlock
    else
      m.reply "Help already sent #{@@help_time} seconds ago. Wait #{HELP_WAIT_DURATION - @@help_time} seconds more."
    end
  end

  def exec_version m
    m.reply Botpop::VERSION
  end

  def exec_code m
    m.reply "https://github.com/pouleta/botpop"
  end

  def exec_help m
    help m
  end

  def exec_help_plugin m
    module_name = m.message.split(" ").last.downcase
    i = Botpop::PLUGINS.map{|e| e.to_s.split(":").last.downcase}.index(module_name)
    if i.nil?
      m.reply "No plugin #{module_name}"
      return
    end
    plugin = Botpop::PLUGINS[i]
    m.reply plugin::HELP.join(', ')
  end

  def exec_troll m
    # hours = (Time.now.to_i - Time.gm(2015, 04, 27, 9).to_i) / 60 / 60
    s = Botpop::Builtins.get_msg m
    url = "http://www.fuck-you-internet.com/delivery.php?text=#{s}"
    m.reply url
  end

end
