default[:scalr_server][:config_dir] = '/etc/scalr-server'
default[:scalr_server][:install_root] = '/opt/scalr-server'
default[:scalr_server][:version] = '5.1.1'

# Routing tunables
# The defaults below are for a single host install.
default[:scalr_server][:routing][:endpoint_scheme] = 'http'
default[:scalr_server][:routing][:endpoint_host] = 'CHANGEME'

default[:scalr_server][:routing][:graphics_scheme] = node.scalr_server.routing.endpoint_scheme
default[:scalr_server][:routing][:graphics_host] = node.scalr_server.routing.endpoint_host
default[:scalr_server][:routing][:graphics_path] = '/graphics'

default[:scalr_server][:routing][:plotter_scheme] = node.scalr_server.routing.endpoint_scheme
default[:scalr_server][:routing][:plotter_host] = node.scalr_server.routing.endpoint_host
default[:scalr_server][:routing][:plotter_port] = 8000


# App tunables
default[:scalr_server][:app][:enable] = true
default[:scalr_server][:app][:admin_user] = 'admin'
default[:scalr_server][:app][:admin_password] = 'CHANGEME'
default[:scalr_server][:app][:id] = 'CHANGEME'

default[:scalr_server][:app][:email_from_address] = 'scalr@scalr.example.com'
default[:scalr_server][:app][:email_from_name] = 'Scalr Service'

default[:scalr_server][:app][:ip_range] = '127.0.0.1/32'

default[:scalr_server][:app][:instances_connection_policy] = 'auto'

default[:scalr_server][:app][:user] = 'scalr'


# Web tunables
default[:scalr_server][:web][:enable] = true


# MySQL tunables
default[:scalr_server][:mysql][:enable] = true
default[:scalr_server][:mysql][:host] = '127.0.0.1'
default[:scalr_server][:mysql][:bind] = '127.0.0.1'
default[:scalr_server][:mysql][:port] = 3306

default[:scalr_server][:mysql][:scalr_user] = 'scalr'
default[:scalr_server][:mysql][:root_password] = 'CHANGEME'
default[:scalr_server][:mysql][:scalr_password] = 'CHANGEME'
default[:scalr_server][:mysql][:server_debian_password] = 'CHANGEME'
default[:scalr_server][:mysql][:server_repl_password] = 'CHANGEME'
default[:scalr_server][:mysql][:scalr_allow_connections_from] = '%'

default[:scalr_server][:mysql][:scalr_dbname] = 'scalr'
default[:scalr_server][:mysql][:analytics_dbname] = 'analytics'

default[:scalr_server][:mysql][:user] = 'mysql'


# Cron tunables
default[:scalr_server][:cron][:enable] = true


# Worker tunables
default[:scalr_server][:worker][:enable] = true
default[:scalr_server][:worker][:plotter_bind_scheme] = 'http'
default[:scalr_server][:worker][:plotter_bind_host] = '0.0.0.0'
default[:scalr_server][:worker][:plotter_bind_port] = 8000


# Rrd tunables
default[:scalr_server][:rrd][:enable] = true
default[:scalr_server][:rrd][:user] = 'rrdcached'


# Supervisor tunables
default[:scalr_server][:supervisor][:enable] = true
default[:scalr_server][:supervisor][:user] = 'root'

# TODO - Expose port, endpoint_host, scheme. ALl of that should be part of another attribute group (e.g. "routing")


# Attributes includes from other cookbooks. We need to include those because we refer to them in our own recipes,
# and don't want to have to ensure that those cookbooks are in the runlist to be able to use the attributes.
include_attribute  'rackspace_timezone'
include_attribute  'php'

# Supervisor configuration (there unfortunately is no better way to override it).
default['supervisor']['dir'] = "#{node.scalr_server.install_root}/etc/supervisor/conf.d"
default['supervisor']['conffile'] = "#{node.scalr_server.install_root}/etc/supervisor/supervisord.conf"

