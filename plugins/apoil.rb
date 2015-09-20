class APoil < Botpop::Plugin
  include Cinch::Plugin

  match(/.*/, use_prefix: false, method: :apoil)

  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def apoil m
    if not (CONFIG["words"] & m.message.split).empty?
      m.reply "apoil"
    end
  end

end
