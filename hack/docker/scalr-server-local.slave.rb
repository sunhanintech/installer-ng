# Enable the DB.
# Other MySQL settings are placed in the main configuration file.
mysql[:enable] = true
mysql[:server_id] = 2
mysql[:allow_remote_root] = true

mysql[:scalr_user] = 'scalr_ro'
mysql[:scalr_privileges] = [:select]
