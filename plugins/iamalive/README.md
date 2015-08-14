# I Am Alive

I am alive is a plugin, that allows to bot to answer to me :)

## Initialization

### Database

Firstly, create the database and migrate it. To do this, use the following command. It needs ``sqlite3`` connector.

```bash
sequel -m plugins/iamalive/migrations sqlite://plugins/iamalive/db.sqlite3
```

You can change the name of the database via the global configuration file (see the example).

### User / Admin

Only authorized users have the rights to administrate the iaa plugin.
Only when there is no administrator (by default), you can use the command "!iaa user add NICK" to add your NICK to the database.
Be sure you have a protected identity.

Then, only administrators can add / remove admin from the list.
