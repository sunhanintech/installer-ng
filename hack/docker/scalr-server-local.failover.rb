# Enable web for tests, shut off the rest of the app

# Can be enabled now
proxy[:enable] = true
web[:enable] = true
memcached[:enable] = true

# Standby
rrd[:enable] = false
service[:enable] = false
cron[:enable] = false

# Is deployed somewhere else
mysql[:enable] = false


# This is a failover, we don't want it to try and write to the DB when initializing the app.
app[:skip_db_initialization] = true

# Different hosts on the failover.
app[:mysql_scalr_host] = 'repl-db'
app[:mysql_analytics_host] = 'repl-ca'

# Legacy syntax (just for testing)
app[:memcached_host] = '127.0.0.1'
app[:memcached_port] = 11211

proxy[:app_upstreams] = ['127.0.0.1:6000']
proxy[:plotter_upstreams] = ['127.0.0.1:6100']
proxy[:graphics_upstreams] = ['127.0.0.1:6200']

