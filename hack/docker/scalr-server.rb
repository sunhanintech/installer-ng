# Important note: any time you make changes to this file, you need to re-execute
# scalr-server-ctl reconfigure

# Disable everything by default. This ensures we only install what we specifically
# enable.
enable_all false

# Set up routing. You'll need to change this based on your environment

# The two lines below are NOT configuration settings. They're just variables to minimize
# repetition.
proto = 'http'            # Set this to https if you enable SSL and have a valid cert.
endpoint = 'example.com'  # Host name or IP of your proxy server.

# These settings control the endpoints that are advertised to end users. Since we're
# proxying everything, they should all be the same.
routing[:endpoint_scheme] = proto
routing[:endpoint_host] = endpoint

routing[:graphics_scheme] = proto
routing[:graphics_host] = endpoint

routing[:plotter_scheme] = proto
routing[:plotter_host] = endpoint
routing[:plotter_port] = if proto == 'http' then 80 else 443 end

# Point the app to the Scalr main DB server.
app[:mysql_scalr_host] = 'db'   # Change this to the hostname / IP of your Scalr main DB server.
app[:mysql_scalr_port] = 3306   # Make sure this matches the MySQL bind port.

# Point the app to the Scalr Cost Analytics DB server.
app[:mysql_analytics_host] = 'ca'   # Change this to the hostname / IP of your Scalr main DB server.
app[:mysql_analytics_port] = 3306   # Make sure this matches the MySQL bind port.

# Point the app to Memcached
app[:memcached_host] = 'mc'   # Change this to the hostname / IP of your Memcached server.
app[:memcached_port] = 11211  # Change this to the Memcached bind port.

# App settings
app[:ip_ranges] = ['0.0.0.0/0']   # Change this to a list of IP ranges that covers all the IPs used by your Scalr servers.
app[:configuration] = {}          # Inject extra Scalr configuration here if you'd like.

# Configure the proxy.
proxy[:app_upstreams] = ['app-1:6000', 'app-2:6000']  # Change this to a list of hostname:port that corresponds to your app servers.
proxy[:plotter_upstreams]  = ['stats:5000']           # Same, but for your plotter server (you should only have one!), which should be running on your stats server.
proxy[:graphics_upstreams] = ['stats:6000']           # Same, but for your graphics server, which should be running on your stats server as well.

proxy[:bind_host] = '0.0.0.0'   # Make sure the proxy doesn't listen on a local address

# SSL settings. Note that all SSL settings are ignored if ssl_enable isn't set to true.
proxy[:ssl_enable] = true                     # Unless you're setting up SSL, set this to Fale.
proxy[:ssl_redirect] = false                  # Whether to redirect to HTTPS when Scalr is accessed over HTTP. Set this to true if your cert is valid.
proxy[:ssl_cert_path] = '/ssl/ssl-test.crt'   # Path to your SSL cert
proxy[:ssl_key_path] = '/ssl/ssl-test.key'    # Path to matching SSL key

# App server settings.
# This is all self-explanatory, but make sure those settings match your proxy[:app_upstreams] setting.
web[:app_bind_host] = '0.0.0.0'
web[:app_bind_port] = 6000

# Graphics server settings.
# Make sure those settings match your proxy[:graphics_upstreams] setting.
web[:graphics_bind_host] = '0.0.0.0'
web[:graphics_bind_port] = 6000

# Plotter server settings.
# Make sure those settings match your proxy[:plotter_upstreams] setting.
service[:plotter_bind_host] = '0.0.0.0'
service[:plotter_bind_port] = 5000

# MySQL settings.
# Since we're deploying multi-host, we make sure MySQL listens on all interfaces.
mysql[:bind_host] = '0.0.0.0'
mysql[:bind_port] = 3306

# Memcached settings.
# This is similar to the MySQL settings above.
memcached[:bind_host] = '0.0.0.0'
memcached[:bind_port] = 11211
