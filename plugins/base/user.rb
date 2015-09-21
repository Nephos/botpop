class Base

  def find_and_exec(name)
    u = User.where(name: name).first
    if u
      yield u
    else
      m.reply "no such user"
    end
  end

  def self.cmd_allowed? m, groups=["admin"], verbose=true
    user = User.where(name: m.user.authname).where("groups @> '{#{groups.join(',')}}'").first
    if user.nil?
      m.reply "No authorized" if verbose
      return false
    else
      return true
    end
  end

  def cmd_allowed? m, groups=["admin"], verbose=true
    Base.cmd_allowed?(m, groups, verbose)
  end

  def user_register m
    return m.reply "You are not connected" if m.user.authname.nil?
    begin
      admin = (User.count == 0)
      u = User.create(name: m.user.authname,
                      admin: admin,
                      groups: [admin ? 'admin' : 'default'])
      m.reply "Welcome ##{u.id} #{u.name}"
    rescue => err
      m.reply "Cannot register #{m.user.authname}"
    end
  end

  def user_ls m
    c = User.count
    m.reply User.limit(20).all.map(&:name).join(', ')
    if c > 20
      m.reply "And #{c-20} more"
    end
  end

  def user_group_ls m, name
    cmd_allowed? m
    find_and_exec(name) do |u|
      m.reply u.groups.join(', ')
    end
  end

  def user_group_add m, name, group
    cmd_allowed? m
    find_and_exec(name) do |u|
      u.update(groups: (u.groups + [group]))
      m.reply "group #{group} added to #{u.name}"
    end
  end

  def user_group_rm m, name, group
    cmd_allowed? m
    find_and_exec(name) do |u|
      u.update(groups: (u.groups - [group]))
      m.reply "group #{group} removed from #{u.name}"
    end
  end

end
