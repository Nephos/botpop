#encoding: utf-8

class Network < Botpop::Plugin
  include Cinch::Plugin

  match("!ping", use_prefix: false, method: :exec_ping)
  match(/!ping #{Botpop::TARGET}\Z/, use_prefix: false, method: :exec_ping_target)
  match(/!httping #{Botpop::TARGET}\Z/, use_prefix: false, method: :exec_ping_http)
  match(/!dos #{Botpop::TARGET}\Z/, use_prefix: false, method: :exec_dos)
  match(/!fok #{Botpop::TARGET}\Z/, use_prefix: false, method: :exec_fok)
  match(/!trace #{Botpop::TARGET}\Z/, use_prefix: false, method: :exec_trace)
  match(/!poke #{Botpop::TARGET}\Z/, use_prefix: false, method: :exec_poke)

  HELP = ["!ping", "!ping [ip]", "!httping [ip]",
          "!dos [ip]", "!fok [nick]", "!trace [ip]", "!poke [nick]"]
  ENABLED = config['enable'].nil? ? true : config['enable']
  CONFIG = config

  private
  # Conversion of the string to value in ms
  def self.config_string_to_time(value)
    value.match(/\d+ms\Z/) ? value.to_f / 100.0 : value.to_f
  end
  public

  DOS_DURATION = config['dos_duration'] || '2s'
  DOS_WAIT_DURATION_STRING = config['dos_wait'] || '5s'
  DOS_WAIT_DURATION = config_string_to_time DOS_WAIT_DURATION_STRING

  # Trace is complexe. 3 functions used exec_trace_display_lines, exec_trace_with_time, exec_trace
  TRACE_DURATION_INIT_STRING_DEFAULT = "0.3s"
  TRACE_DURATION_INIT_STRING = config['trace_duration_init'] || TRACE_DURATION_INIT_STRING_DEFAULT
  TRACE_DURATION_INCR_STRING_DEFAULT = "0.1s"
  TRACE_DURATION_INCR_STRING = config['trace_duration_incr'] || TRACE_DURATION_INCR_STRING_DEFAULT
  TRACE_DURATION_INIT = config_string_to_time TRACE_DURATION_INIT_STRING
  TRACE_DURATION_INCR = config_string_to_time TRACE_DURATION_INCR_STRING

  # @param what [Net::Ping::External]
  # @param what [Net::Ping::HTTP]
  def ping_with m, what
    ip = Botpop::Builtins.get_ip m
    p = what.new ip
    str = p.ping(ip) ? "#{(p.duration*100.0).round 2}ms (#{p.host})" : 'failed'
    m.reply "#{ip} > #{what.to_s.split(':').last} ping > #{str}"
  end

  def exec_ping m
    m.reply "#{m.user} > pong"
  end

  def exec_ping_target m
    ping_with m, Net::Ping::External
  end

  def exec_ping_http m
    ping_with m, Net::Ping::HTTP
  end

  def exec_poke m
    nick = Botpop::Builtins.get_ip_from_nick(m)[:nick]
    ip = Botpop::Builtins.get_ip_from_nick(m)[:ip]
    return m.reply "User '#{nick}' doesn't exists" if ip.nil?
    # Display
    response = Botpop::Builtins.ping(ip) ? "#{(p.duration*100.0).round 2}ms (#{p.host})" : "failed"
    m.reply "#{nick} > poke > #{response}"
  end


  def dos_check_ip(m, ip)
    return true if Botpop::Builtins.ping(ip)
    m.reply "Cannot reach the host '#{ip}'"
    return false
  end

  def dos_replier m, ip, s
    if s.nil?
      m.reply "The dos has failed"
    elsif Botpop::Builtins.ping(ip)
      m.reply "Sorry, the target is still up !"
    else
      m.reply "Target down ! --- #{s}"
    end
  end

  # This function avoid overusage of the resources by using mutex locking.
  # It execute the lamdba function passed as 2sd parameter if resources are ok
  # At the end of the attack, it wait few seconds (configuration) before
  # releasing the resources and permit a new attack.
  #
  # @arg lambda [Lambda] lambda with one argument (m). It wil be executed
  def dos_execution(m, lambda)
    @dos ||= Mutex.new
    if @dos.try_lock
      lambda.call(m)
      sleep DOS_WAIT_DURATION
      @dos.unlock
    else
      m.reply "Wait for the end of the last dos"
    end
  end

  def dos_ip(ip)
    return Botpop::Builtins.dos(ip, DOS_DURATION).split("\n")[3].to_s rescue nil
  end

  def exec_dos m
    dos_execution m, lambda {|m|
      ip = Botpop::Builtins.get_ip m
      return if not dos_check_ip(m, ip)
      m.reply "Begin attack against #{ip}"
      s = dos_ip(ip)
      dos_replier m, ip, s
    }
  end

  def exec_fok m
    dos_execution m, lambda {|m|
      nick = Botpop::Builtins.get_ip_from_nick(m)[:nick]
      ip = Botpop::Builtins.get_ip_from_nick(m)[:ip]
      return m.reply "User '#{nick}' doesn't exists" if ip.nil?
      return m.reply "Cannot reach the host '#{ip}'" if not Botpop::Builtins.ping(ip)
      s = dos_ip(ip)
      r = Botpop::Builtins.ping(ip) ? "failed :(" : "down !!!"
      m.reply "#{nick} : #{r} #{s}"
    }
  end

  def trace_display_lines m, lines
    lines.select!{|e| not e.include? "no reply" and e =~ /\A \d+: .+/}
    duration = TRACE_DURATION_INIT
    lines.each do |l|
      m.reply l
      sleep duration
      duration += TRACE_DURATION_INCR
    end
    m.reply 'finished'
  end

  def trace_with_time ip
    t1 = Time.now
    s = Botpop::Builtins.trace ip
    t2 = Time.now
    return [s, t1, t2]
  end

  # see {trace_execution}. Seem system without sleep
  #
  # @arg lambda [Lambda] lambda with one argument (m). It wil be executed
  def trace_execution(m, lambda)
    @trace ||= Mutex.new
    if @trace.try_lock
      lambda.call(m) rescue nil
      @trace.unlock
    else
      m.reply "A trace is still running"
    end
  end

  def exec_trace m
    trace_execution m, lambda {|m|
      ip = Botpop::Builtins.get_ip m
      m.reply "It can take time"
      begin
        # Calculations
        s, t1, t2 = trace_with_time ip
        m.reply "Trace executed in #{(t2 - t1).round(3)} seconds"
      rescue => e
        m.reply "Sorry, but the last author of this plugin is so stupid his mother is a tomato"
      end
      # Display
      trace_display_lines m, s
    }
  end

end
