# encoding: utf-8
class Arguments

  # @arg : name [String] the option to search
  # @arg : name [Array] the options to search (multiples keys avaliables)
  def get_one_argument(name, default_value)
    if name.is_a? String
      i = @argv.index(name)
    elsif name.is_a? Array
      i = nil
      name.each{|n| i ||= @argv.index(n) }
    else
      raise ArgumentError, "name must be an Array or a String, not #{name.class}"
    end
    return default_value if i.nil?
    value = @argv[i + 1]
    return value.empty? ? default_value : value
  end

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

  DEFAULT_SERVER = 'irc.freenode.org'
  def server
    get_one_argument ['--ip', '-s'], DEFAULT_SERVER
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

  DEFAULT_NICK = 'cotcot'
  def nick
    get_one_argument ['-n', '-u'], DEFAULT_NICK
  end

  def user
    get_one_argument ['-u', '-n'], DEFAULT_NICK
  end

  DEFAULT_CONFIG = "modules_config.yml"
  def config_file
    get_one_argument ['--config'], DEFAULT_CONFIG
  end

  DEFAULT_PLUGIN_DIR = 'plugins'
  def plugin_directory
    get_one_argument ['--plugin_directory'], DEFAULT_PLUGIN_DIR
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
