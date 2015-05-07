# encoding: utf-8
class Arguments

  def initialize argv
    @argv = argv

    i = 0
    debugvars = []
    argv = @argv.dup
    while i
      i = argv.index('--debug')
      if i
        debugvars << argv[i + 1]
        argv = argv[(i+2)..(-1)]
      end
    end
    debugvars.each{|dv| eval("$debug_#{dv}=true")}
  end

  def server
    i = @argv.index('--ip') || @argv.index('-s')
    return 'irc.freenode.org' if i.nil? or @argv.size <= i
    return @argv[i + 1]
  end

  def channels
    i = @argv.index '-c'
    return ['#equilibre'] if i.nil?
    chans = @argv[(i+1)..-1]
    i = chans.index{|c| c[0] == '-'}
    i = i.nil? ? -1 : i - 1
    chans = chans[0..i]
    return chans.map{|c| c[0] == '#' ? c : "##{c}"}
  end

  def port
    if ssl and not @argv.index('-p')
      return 7000
    else
      i = @argv.index('-p')
      return 6667 if i.nil?
      return @argv[i + 1].to_i
    end
  end

  def ssl
    return !@argv.include?('--no-ssl')
  end

  def nick
    i = @argv.index('-n') || @argv.index('-u')
    return 'cotcot' if i.nil?
    return @argv[i + 1]
  end

  def user
    i = @argv.index('-u') || @argv.index('-n')
    return 'cotcot' if i.nil?
    return @argv[i + 1]
  end

  DEFAULT_CONFIG = "modules_config.yml"
  def config_file
    i = @argv.index('--config')
    return DEFAULT_CONFIG if i.nil?
    return @argv[i + 1]
  end

  DEFAULT_PLUGIN_DIR = 'plugins'
  def plugin_directory
    i = @argv.index('--plugin-directory')
    return DEFAULT_PLUGIN_DIR if i.nil? or not Dir.exists?(@argv[i + 1])
    return @argv[i + 1]
  end

  def disable_plugins
    i = 0
    plugins = []
    argv = @argv.dup
    while i
      i = argv.index('--plugin-disable')
      if i
        plugin = argv[i + 1]
        plugin = plugin + '.rb' if plugin[-4..-1] != '.rb'
        plugins << File.expand_path(plugin, plugin_directory)
        argv = argv[(i+2)..(-1)]
      end
    end
    return plugins
  end

end
