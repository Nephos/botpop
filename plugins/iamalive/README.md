# I Am Alive

I am alive is a plugin, that allows to bot to answer to me :)

## Initialization

### Database

Firstly, create the database and migrate it. To do this, use the following command.
In the ``modules_config.yml`` file, configure it for your engine.
As it use sequel engine, it is compatible with sqlite, mysql, postgres, etc.
Checkout the [sequel documentaiton](http://sequel.jeremyevans.net/documentation.html) for more informations.
Then, execute one of two:

```bash
sequel -m plugins/iamalive/migrations sqlite://plugins/iamalive/db.sqlite3
sequel -m plugins/iamalive/migrations postgres://root:toor@localhost:5432/botpop_iamalive
...
```

You can change the name of the database via the global configuration file (see the example).

### User / Admin

Only authorized users have the rights to administrate the iaa plugin.
Only when there is no administrator (by default), you can use the command "!iaa user add NICK" to add your NICK to the database.
Be sure you have a protected identity.

Then, only administrators can add / remove admin from the list.
