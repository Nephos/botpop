#encoding: utf-8

module BotpopPlugins
  module Network

    MATCH = lambda do |parent, plugin|
      parent.on :message, "!ping" do |m| plugin.exec_ping m end
      parent.on :message, /!ping #{Botpop::TARGET}\Z/ do |m| plugin.exec_ping_target m end
      parent.on :message, /!dos #{Botpop::TARGET}\Z/ do |m| plugin.exec_dos m end
      parent.on :message, /!fok #{Botpop::TARGET}\Z/ do |m| plugin.exec_fok m end
      parent.on :message, /!trace #{Botpop::TARGET}\Z/ do |m| plugin.exec_trace m end
      parent.on :message, /!poke #{Botpop::TARGET}\Z/ do |m| plugin.exec_poke m end
    end

    def self.exec_ping m
      m.reply "#{m.user} > pong"
    end

    def self.exec_ping_target m
      ip = Builtin.get_ip m
      p = Net::Ping::External.new ip
      str = p.ping(ip) ? "#{(p.duration*100.0).round 2}ms (#{p.host})" : 'failed'
      m.reply "#{ip} > ping > #{str}"
    end

    def self.exec_poke m
      nick = Builtin.get_ip_from_nick(m)[:nick]
      ip = Builtin.get_ip_from_nick(m)[:ip]
      return m.reply "User '#{nick}' doesn't exists" if ip.nil?
      # Display
      response = Builtin.ping(ip) ? "#{(p.duration*100.0).round 2}ms (#{p.host})" : "failed"
      m.reply "#{nick} > poke > #{response}"
    end

    DOS_DURATION = "2s"
    DOS_WAIT = 5
    def self.exec_dos_check_ip(m, ip)
      return true if Builtin.ping(ip)
      m.reply "Cannot reach the host '#{ip}'"
      @dos.unlock
      return false
    end

    def self.exec_dos m
      @dos ||= Mutex.new
      if @dos.try_lock
        ip = Builtin.get_ip m
        return if not exec_dos_check_ip(m, ip)
        m.reply "Begin attack against #{ip}"
        s = Builtin.dos(ip, DOS_DURATION).split("\n")[3].to_s rescue s = nil
        m.reply (Builtin.ping(ip) ? "failed :(" : "down !!!") + " " + s if s
        sleep DOS_WAIT
        @dos.unlock
      else
        m.reply "Wait for the end of the last dos"
      end
    end

    def self.exec_fok m
      nick = Builtin.get_ip_from_nick(m)[:nick]
      ip = Builtin.get_ip_from_nick(m)[:ip]
      return m.reply "User '#{nick}' doesn't exists" if ip.nil?
      return m.reply "Cannot reach the host '#{ip}'" if not Builtin.ping(ip)
      s = Builtin.dos(ip, DOS_DURATION).split("\n")[3].to_s
      m.reply "#{nick} : " + (Builtin.ping(ip) ? "failed :(" : "down !!!") + " " + s
    end

    # Trace is complexe. 3 functions used exec_trace_display_lines, exec_trace_with_time, exec_trace
    TRACE_DURATION_INIT = 0.3
    TRACE_DURATION_INCR = 0.1
    def self.exec_trace_display_lines m, lines
      lines.select!{|e| not e.include? "no reply" and e =~ /\A \d+: .+/}
      duration = TRACE_DURATION_INIT
      lines.each do |l|
        m.reply l
        sleep duration
        duration += TRACE_DURATION_INCR
      end
      m.reply 'finished'
    end

    def self.exec_trace_with_time ip
      t1 = Time.now
      s = Builtin.trace ip
      t2 = Time.now
      return [s, t1, t2]
    end

    def self.exec_trace m
      @trace ||= Mutex.new
      if @trace.try_lock
        ip = Builtin.get_ip m
        m.reply "It can take time"
        begin
          # Calculations
          s, t1, t2 = exec_trace_with_time ip
          m.reply "Trace executed in #{(t2 - t1).round(3)} seconds"
          @trace.unlock
        rescue => e
          m.reply "Sorry, but the last author of this plugin is so stupid his mother is a tomato"
          @trace.unlock
        end
        # Display
        exec_trace_display_lines m, s
      else
        m.reply "Please retry after when the last trace end"
      end
    end

  end
end
