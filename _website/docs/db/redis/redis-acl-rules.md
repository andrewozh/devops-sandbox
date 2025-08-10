# Redis ACL Rules

:::note Official documentation
https://redis.io/docs/latest/operate/oss_and_stack/management/security/acl/
:::

```
# Create a read-only user
user reader on +@read ~* &* -@dangerous >reader_password

# Create a write user with specific key pattern access
user writer on +@write +@read ~app:* -@dangerous >writer_password

# Create an admin user with full access
user admin on ~* &* +@all >admin_password

# Create application-specific user
user app_user on ~cache:* ~session:* +get +set +del +exists +expire +ttl >app_password
```

## ACL Rule Syntax:

on/off - Enable or disable the user
+@category - Allow commands in a category (e.g., @read, @write, @all)
-@category - Deny commands in a category
+command - Allow specific command
-command - Deny specific command
~pattern - Key pattern access (e.g., ~* for all keys, ~app:* for keys starting with "app:")
&pattern - Pub/Sub channel pattern access
>password - Set user password

## Common ACL Categories

@read - Read operations (GET, MGET, etc.)
@write - Write operations (SET, DEL, etc.)
@keyspace - All key-related commands
@string - String commands
@list - List commands
@hash - Hash commands
@stream - Stream commands
@admin - Administrative commands
@dangerous - Dangerous commands (FLUSHDB, CONFIG, etc.)

## Commands

```
# List all users
ACL LIST

# Create a new user
ACL SETUSER john on >john_password ~cached:* +get +set +del

# Create read-only user
ACL SETUSER readonly on >readonly_pass ~* +@read -@dangerous

# Create user with specific database access
ACL SETUSER dbuser on >dbpass ~db:* +@all -flushdb -flushall -config

# Check user permissions
ACL GETUSER john

# Delete a user
ACL DELUSER john

# Save ACL to persistence
ACL SAVE

```
