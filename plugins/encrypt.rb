require 'tor257/core'
require 'base64'

class Encrypt < Botpop::Plugin
  include Cinch::Plugin

  match(/^!tor257 (c|d) (\w+) (.+)/, use_prefix: false, method: :exec_tor257)

  HELP = ["!tor257 <c|d> keyphrase data"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def exec_tor257 m, type, k, d
    d = Base64.decode64(d.strip) if type == 'd'
    e = Tor257::Message.new(d).encrypt(Tor257::Key.new(k)).to_s
    e = Base64.encode64(e) if type == 'c'
    m.reply e
  end

end
