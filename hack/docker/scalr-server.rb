enable_all false

app[:mysql_scalr_host] = 'db'
app[:mysql_scalr_port] = 3306

app[:mysql_analytics_host] = 'ca'
app[:mysql_analytics_port] = 3306

app[:memcached_host] = 'mc'
app[:memcached_port] = 11211

proxy[:app_upstreams] = ['app-1:6000', 'app-2:6000']
proxy[:plotter_upstreams]  = ['stats:5000']
proxy[:graphics_upstreams] = ['stats:6000']

proxy[:bind_host] = '0.0.0.0'
proxy[:ssl_enable] = true
proxy[:ssl_redirect] = false
proxy[:ssl_cert_path] = '/ssl/ssl-test.crt'
proxy[:ssl_key_path] = '/ssl/ssl-test.key'

web[:app_bind_host] = '0.0.0.0'
web[:app_bind_port] = 6000

web[:graphics_bind_host] = '0.0.0.0'
web[:graphics_bind_port] = 6000

service[:plotter_bind_host] = '0.0.0.0'
service[:plotter_bind_port] = 5000

mysql[:bind_host] = '0.0.0.0'
mysql[:bind_port] = 3306

memcached[:bind_host] = '0.0.0.0'
memcached[:bind_port] = 11211
