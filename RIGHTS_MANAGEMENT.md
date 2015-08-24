# How to use rights ?

In your plugin, add the method ``cmd_allowed?`` and use it like in the following example:

```ruby
class Plugin < Botpop::Plugin
  ...
  def cmd_allowed? m
    return if not Base.cmd_allowed? m, ["groupname"]
  end

  def exec_some_match m
    return if not cmd_allowed? m
  end
```
