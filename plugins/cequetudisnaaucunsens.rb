class CeQueTuDisNAAucunSens < Botpop::Plugin
  include Cinch::Plugin

  match(/^[^!].+$/, use_prefix: false, method: :say_random_sentence)
  match(/^!random_sentence register ([^|]+)\|(.+)/, use_prefix: false, method: :register_trigger)
  match(/^!random_sentence remove (.+)/, use_prefix: false, method: :remove_trigger)

  HELP = ["!random_sentence register trigger | content",
          "!random_sentence remove trigger" ]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def cmd_allowed? m
    return Base.cmd_allowed? m, ["random_sentence"]
  end

  def say_random_sentence m
    trigger = I18n.transliterate(m.message).strip
    r = Base::DB[:random_sentences].where(enabled: true).where('? ~* "trigger"', trigger).select(:content).first
    return if r.nil?
    m.reply r[:content].split(' ').shuffle.join(' ')
  end

  def say_random m
    m.reply %w(ce que tu dis n'a aucun sens).shuffle.join(' ')
  end

  def register_trigger m, t, c
    return if not cmd_allowed? m
    t = t.triggerize
    begin
      Base::DB[:random_sentences].insert(trigger: t,
                                   content: c.strip,
                                   author: m.user.authname,
                                   created_at: Time.now.utc)
      m.reply "The trigger \"#{t.strip}\" will raise \"#{c.strip}\""
    rescue => _err
      m.reply "Error. Cannot register this trigger"
      m.reply _err
    end
  end

  def remove_trigger m, t
    return if not cmd_allowed? m
    t = t.triggerize
    n = Base::DB[:random_sentences].where(trigger: t).delete
    m.reply "Deleted #{n} trigger"
  end

end

class String
  def triggerize
    t = self.dup
    t = I18n.transliterate(t).strip
    t = Regexp.quote(t)
    t.gsub!(/((a)a+)/i, '\2') # ... i know :(
    t.gsub!(/((e)e+)/i, '\2')
    t.gsub!(/((i)i+)/i, '\2')
    t.gsub!(/((o)o+)/i, '\2')
    t.gsub!(/((u)u+)/i, '\2')
    t.gsub!(/((y)y+)/i, '\2')
    t.gsub!(/([aeiouy])/, '\1+')
    # TODO: not only " " but also ponctuation etc.
    t = "^(.* )?#{t}( .*)?$"
    return t
  end
end
