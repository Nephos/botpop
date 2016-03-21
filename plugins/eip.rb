class Eip < Botpop::Plugin
  include Cinch::Plugin

  match(/!eip add (.*)/, use_prefix: false, method: :exec_add)
  match(/!eip ls/, use_prefix: false, method: :exec_ls)
  match(/!eip (\d+)/, use_prefix: false, method: :exec_id)

  HELP = ["!eip add ...", "!eip ls", "!eip id"]
  ENABLED = config['enable'].nil? ? false : config['enable']
  CONFIG = config

  def exec_add(m, title)
    begin
      Base::DB[:eips].insert(author: m.user.authname,
                             title: title,
                             created_at: Time.now)
      m.reply "Ok ! #{title} is a new eip"
    rescue
      m.reply "Err"
    end
  end

  def exec_id(m, id)
    all = Base::DB[:eips].where(id: Integer(id)).first
    m.reply all[:title] rescue m.reply("no such id")
  end

  def exec_ls(m)
    all = Base::DB[:eips].limit(3).reverse.all
    all.each{|e| m.reply e[:title]}
    n = Base::DB[:eips].count
    m.reply("There is #{n} elements")
  end

end
