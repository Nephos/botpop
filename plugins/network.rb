#encoding: utf-8

module BotpopPlugins

  def self.exec_intra m
    m.reply Action.intra_state
  end

  INTRA_PING_SLEEP = 30
  def self.exec_intra_on m
    @intra ||= Mutex.new
    if @intra.try_lock
      begin
        m.reply "INTRANET SPY ON"
        @intra_on = true
        sleep 1
        loop do
          break if @intra_on == false
          m.reply Action.intra_state
          sleep INTRA_PING_SLEEP
        end
        @intra.unlock
      rescue
        @intra.unlock
      end
    else
      m.reply "INTRA SPY ALREADY ON"
    end
  end

  def self.exec_intra_off m
    @intra_on = false
    m.reply "INTRA SPY OFF"
  end

  def self.exec_ping m
    m.reply "#{m.user} pong"
  end

  def self.exec_ping_target m
    ip = get_ip m
    p = Net::Ping::External.new ip
    str = "failed"
    if p.ping?
      str = "#{(p.duration*100.0).round 2}ms (#{p.host})"
    end
    m.reply "#{ip} ping> #{str}"
  end

  DOS_DURATION = "2s"
  DOS_WAIT = 5
  def self.exec_dos m
    @dos ||= Mutex.new
    if @dos.try_lock
      begin
        ip = get_ip m
        if not Action.ping(ip)
          m.reply "Cannot reach the host '#{ip}'"
          raise "Unreachable host"
        end
        m.reply "Begin attack against #{ip}"
        s = Action.dos(ip, DOS_DURATION).split("\n")[3].to_s
        m.reply (Action.ping(ip) ? "failed :(" : "down !!!") + " " + s
        sleep DOS_WAIT
        @dos.unlock
      rescue
        @dos.unlock
      end
    else
      m.reply "Wait for the end of the last dos"
    end
  end

  def self.exec_fok m
    nick = get_ip m
    ip = m.target.users.keys.find{|u| u.nick == nick rescue nil}.host rescue nil
    return m.reply "User '#{nick}' doesn't exists" if ip.nil?
    return m.reply "Cannot reach the host '#{ip}'" if not Action.ping(ip)
    s = Action.dos(ip, DOS_DURATION).split("\n")[3].to_s
    m.reply "#{nick} : " + (Action.ping(ip) ? "failed :(" : "down !!!") + " " + s
  end

  def self.exec_trace m
    @trace ||= Mutex.new
    if @trace.try_lock
      begin
        ip = get_ip m
        m.reply "It can take time"
        t1 = Time.now; s = Action.trace ip; t2 = Time.now
        m.reply "Used #{(t2 - t1).round(3)} seconds"
        so = s.select{|e| not e.include? "no reply" and e =~ /\A \d+: .+/}
        @trace.unlock
        duration = 0.3
        so.each{|l| m.reply l; sleep duration; duration += 0.1}
        m.reply "Trace #{ip} done"
      rescue => e
        m.reply "Sorry, but the last author of this plugin is so stupid his mother is a tomato"
        @trace.unlock
      end
    else
      m.reply "Please retry after when the last trace end"
    end
  end

  def self.exec_poke m
    nick = get_ip m
    ip = m.target.users.keys.find{|u| u.nick == nick rescue nil}.host rescue nil
    return m.reply "User '#{nick}' doesn't exists" if ip.nil?
    p = Net::Ping::External.new ip
    str = "failed"
    if p.ping?
      str = "#{(p.duration*100.0).round 2}ms (#{p.host})"
    end
    m.reply "#{nick} poke> #{str}"
  end

end
