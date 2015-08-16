## Plugin Database Extension

You can configure a database to store a large amount of volatiles informations, like the users rights, etc.
To do it, there is an extension, ready to be used.

- configure the database access (for exemple, in the ``modules_config.yml``:
```yaml
plugin:
  database:
    adapter: postgres
    host: localhost
    port: 5432
    user: root
    password: toor
    database: botpop_db
```

  and then, in you plugin

```ruby
class Plugin < Botpop::Plugin
  include Cinch::Plugin
  include Botpop::Plugin::Database

  ...
  if ENABLED
    DB_CONFIG = self.db_config = config(safe: true)['database']
    DB = self.db_connect!
    require_relative 'plugin/model' # if you have a model, include it now
  end

end
```

- create the database and tables. It can be done via 2 ways:
  - migrations: **recommanded**. This is safer and more reliable. There is an example if [iamalive](plugins/iamalive/). Checkout the documentation of the orm: [sequel migrations](http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html).
  - manual: **NOT recommanded**. Create the database and tables manually.

- use it

```ruby
class Plugin ...
  ...
  def search_word m, word
    found = DB[:words].where(word: word).first
    m.reply found ? found[:id] : 'no such word'
  end
end
```

If you want to use models, don't forget to set the "dataset" (association with the right database / table) to avoid conflicts:

```ruby
class Model < Sequel::Model
  set_dataset DB[:admins]
end
```

## Plugin Database::Admin extension

This simple extension allows you to manage users. Simply add to your plugin:

```ruby
  include Botpop::Plugin::Database::Admin
```

It **requires** the basic Database extension.
An admin requires 2 fields: **id** and **user**.

You have to create your own migration/table like ``01_create_admins.rb``:

```ruby
Sequel.migration do
  change do
    create_table(:admins) do
      primary_key :id
      String :user, null: false
    end
  end
end
```

There is 4 methods provided: ``user_add``, ``user_remove``, ``user_list``, and ``cmd_allowed?``.
Then, add your own match in the plugin, like:

```ruby
class Plugin < Botpop::Plugin
  include Cinch::Plugin
  include Botpop::Plugin::Database
  include Botpop::Plugin::Database::Admin

  match(/^!user add (\w+)$/, use_prefix: false, method: :user_add)
  match(/^!user remove (\w+)$/, use_prefix: false, method: :user_remove)
  match(/^!user list$/, use_prefix: false, method: :user_list)
```

