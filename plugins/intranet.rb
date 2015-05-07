#encoding: utf-8

module BotpopPlugins

  MATCH_INTRANET = lambda do |parent|
    parent.on :message, "!intra" do |m| BotpopPlugins::exec_intra m end
    parent.on :message, "!intra on" do |m| BotpopPlugins::exec_intra_on m end
    parent.on :message, "!intra off" do |m| BotpopPlugins::exec_intra_off m end
  end

  def self.exec_intra m
    m.reply Action.intra_state rescue m.reply "I'm buggy. Sorry"
  end

  INTRA_PING_SLEEP = 30
  def self.exec_intra_on m
    @intra ||= Mutex.new
    if @intra.try_lock
      @intra_on = true
      m.reply "INTRANET SPY ON"
      while @intra_on
        m.reply Action.intra_state rescue return @intra.unlock
        sleep INTRA_PING_SLEEP
      end
      @intra.unlock
    else
      m.reply "INTRA SPY ALREADY ON"
    end
  end

  def self.exec_intra_off m
    m.reply @intra_on ? "INTRA SPY OFF" : "INTRA SPY ALREADY OFF"
    @intra_on = false
  end

end
