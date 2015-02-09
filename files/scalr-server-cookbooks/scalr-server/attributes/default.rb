########################
# Defaults Preparation #
########################
require 'set'
require 'resolv'

# All of the below are of course just defaults, they can be overridden by setting the actual routing attributes.

# If you're reading this, this will probably not be very relevant to you. This part of the attributes file basically
# uses ohai data to try and guess good default values. But since you're customizing attributes, you don't really care
# about default values (you'll probably be overriding those)!


# IP Ranges #

# Identify all the ips that appear to be ours
node_ips = Set.new [node[:ipaddress]]
[:local_ipv4_addrs, :public_ipv4_addrs].each { |ipaddress_set|
  begin
    node_ips.merge node[:cloud_v2][ipaddress_set]
  rescue NoMethodError
    # This will happen if the set doesn't exist
    next
  end
}

# Remove any nil IP.
node_ips.reject! { |ipaddress| ipaddress.nil?}

# Whitelist anything that appears to be ours.
default_ip_ranges = node_ips.to_a.collect! { |ipaddress| "#{ipaddress}/32" }


# Endpoint #

# Try and identify the best endpoint we could use. By default, we use the ip address (meh).
default_endpoint = node[:ipaddress]

# Locate all candidates
candidate_endpoints = [node[:fqdn], node[:hostname]]
[:public_hostname, :local_hostname].each { |endpoint_key|
  begin
    candidate_endpoints.push node[:cloud_v2][endpoint_key]
  rescue NoMethodError
    next
  end
}

# Now, is there anything that resolves *directly* to us? If yes, use that.
candidate_endpoints.each { |endpoint|
  begin
    if node_ips.include? Resolv.getaddress endpoint
      default_endpoint = endpoint
      break
    end
  rescue Resolv::ResolvError, ArgumentError
    # This might happen if the hostname doesn't resolve.. Or isn't a hostname
    next
  end
}


#######################
# Installer Internals #
#######################

# Path where the installer should look for configuration files. The installer will look up three files there:
#
# - `scalr-server-secrets.json`: see below (admin_user). This contains passwords, basically.
#
# - `scalr-server.rb`: more or less an attributes file (basically, `default[:scalr_server][:app][:something]` is written
#                      `app[:something]` there), which will be evaluated at startup. If you're reading this, you
#                      probably don't care about that file (since you're passing your own attributes).
#
# - `scalr-server-local.rb`: exactly the same behavior as `scalr-server.rb`. The lcoal file overrides the main file.
default[:scalr_server][:config_dir] = '/etc/scalr-server'

# Unless you're cooking your own scalr-server packages, you shouldn't touch this.
default[:scalr_server][:install_root] = '/opt/scalr-server'


###########
# Routing #
###########

# The defaults below are for a single host install.

# The following settings control the endpoint that Scalr advertises to users (browsers) and managed servers (Scalarizr).
# They must properly point to a Scalr application server, or to a load balancer that forwards traffic to one.
default[:scalr_server][:routing][:endpoint_scheme] = 'http'           # Protocol to use to access the endpoint (http | https)
default[:scalr_server][:routing][:endpoint_host] = default_endpoint   # Host to use to access the endpoint (ip or hostname, hostname recommended)
# TODO - endpoint_port

# The following settings control the endpoint Scalr advertises for load statistics graphics (images). They must point to
# the serving hosting those graphs.
default[:scalr_server][:routing][:graphics_scheme] = 'http'           # Same as above
default[:scalr_server][:routing][:graphics_host] = default_endpoint   # Same as above
default[:scalr_server][:routing][:graphics_path] = 'graphics'         # Relative path where the graphics are served from.

# THe following settings control the endpoint Scalr advertises for the load statistics plotter. This application is
# generates the graphics (which are served at the graphics endpoint), and redirects the client (browser) to the graphics
# endpoint.
default[:scalr_server][:routing][:plotter_scheme] = 'http'            # Same as above
default[:scalr_server][:routing][:plotter_host] = default_endpoint    # Same as above
default[:scalr_server][:routing][:plotter_port] = 80                  # Port to advertise the plotter on (see bind_port below).


#######
# App #
#######

# Whether to enable the app (i.e. create app configuration, etc.). This does *not* control whether the Scalr webserver
# will be launched. The only case where you should realistically set this to `false` is when you're only deploying
# MySQL. Note that enabling `app` also loads the DB structure, and initial data, and performs migrations (so MySQL
# must be available when you run the installer).
default[:scalr_server][:app][:enable] = true

# Admin settings. Note that admin_password *is not used*. Instead, the admin_password must be provided in
# `/etc/scalr-server/scalr-server-secrets.json` (configurable through the `scalr_server.config_dir` attribute). If
# this isn't provided, the installer will auto-generate one (which is probably not what you want if you're reading
# this). View `../libraries/scalr_server.rb` for more information.
default[:scalr_server][:app][:admin_user] = 'admin'
default[:scalr_server][:app][:admin_password] = 'CHANGEME'  # /!\ IGNORED. Place it under `app.admin_password`

# The two following attributes behave just like admin_password: they're ignored.
default[:scalr_server][:app][:id] = 'CHANGEME'              # /!\ IGNORED. Place it under `app.id`.
default[:scalr_server][:app][:secret_key] = 'CHANGEME'      # /!\ IGNORED. Place it under `app.secret_key`.

# User the Scalr app bits should run as.
default[:scalr_server][:app][:user] = 'scalr-app'

# The following settings are passed through to the Scalr configuration file (app/etc/config.yml).
# See `../libraries/config_helper.rb` to see what they map to.
default[:scalr_server][:app][:email_from_address] = 'scalr@scalr.example.com'
default[:scalr_server][:app][:email_from_name] = 'Scalr Service'
default[:scalr_server][:app][:ip_ranges] = default_ip_ranges
default[:scalr_server][:app][:instances_connection_policy] = 'auto'

# App MySQL configuration
default[:scalr_server][:app][:mysql_scalr_host] = '127.0.0.1'
default[:scalr_server][:app][:mysql_scalr_port] = 6280

default[:scalr_server][:app][:mysql_analytics_host] = '127.0.0.1'
default[:scalr_server][:app][:mysql_analytics_port] = 6280

# PHP session cookie lifetime. You can extend or reduce this depending on your security requirements.
default[:scalr_server][:app][:session_cookie_lifetime] = 1800

# Hash of arbitrary configuration parameters to include in the Scalr configuration. This will be deeply merged
# with the default configuration. Note that arrays are *not* deeply merged (so that you can remove values from their
# defaults). Note also that most commonly used settings are exposed as attributes, but that they can be overriden here
# anyway.
#
# Example:
# {
#   :scalr => {
#     :auth_mode => 'ldap',
#     :connections => {
#       :ldap => {
#         :host => 'localhost',
#         ...
#       }
#     }
#   }
# }
default[:scalr_server][:app][:configuration] = {}


#########
# Proxy #
#########

default[:scalr_server][:proxy][:enable] = true

default[:scalr_server][:proxy][:bind_host] = '0.0.0.0'
default[:scalr_server][:proxy][:bind_port] = 80  # Setting this to anything but 80 isn't really supported at this time.

default[:scalr_server][:proxy][:app_upstreams] = ['127.0.0.1:6270']
default[:scalr_server][:proxy][:graphics_upstreams] = ['127.0.0.1:6271']
default[:scalr_server][:proxy][:plotter_upstreams] = ['127.0.0.1:6272']

default[:scalr_server][:proxy][:ssl_enable] = false
default[:scalr_server][:proxy][:ssl_redirect] = true
default[:scalr_server][:proxy][:ssl_bind_port] = 443  # Setting this to anything but 443 isn't really supported at this time.
default[:scalr_server][:proxy][:ssl_cert_path] = nil
default[:scalr_server][:proxy][:ssl_key_path] = nil



#######
# Web #
#######

# Whether to enable the Scalr web app.
default[:scalr_server][:web][:enable] = true

default[:scalr_server][:web][:app_bind_host] = '127.0.0.1'
default[:scalr_server][:web][:app_bind_port] = 6270

default[:scalr_server][:web][:graphics_bind_host] = '127.0.0.1'
default[:scalr_server][:web][:graphics_bind_port] = 6271


#########
# MySQL #
#########

# Whether to enable MySQL. This will configure MySQL, create a user for Scalr, and create the Scalr databases (but
# it will *not* load their structure, data, or migrate them).
# If you want to use your own MySQL server (or e.g. RDS), disable this, create a user, and create the databases (and
# add grants).
default[:scalr_server][:mysql][:enable] = true

# Configuration for MySQL
default[:scalr_server][:mysql][:bind_host] = '127.0.0.1'  # Host MySQL should listen on.
default[:scalr_server][:mysql][:bind_port] = 6280         # Port MySQL should bind to.

# User configuration for MySQL. The passwords here behave just like `app.admin_password`
default[:scalr_server][:mysql][:root_password] = 'CHANGEME'  # /!\ IGNORED. Place it under `mysql.root_password`.
default[:scalr_server][:mysql][:scalr_user] = 'scalr'
default[:scalr_server][:mysql][:scalr_password] = 'CHANGEME' # /!\ IGNORED. Place it under `mysql.scalr_password`.
default[:scalr_server][:mysql][:scalr_allow_connections_from] = '%'

# Database configuration for MySQL.
default[:scalr_server][:mysql][:scalr_dbname] = 'scalr'
default[:scalr_server][:mysql][:analytics_dbname] = 'analytics'

# TODO - Option to only create specific tables

# User MySQL should run as.
default[:scalr_server][:mysql][:user] = 'scalr-mysql'


########
# Cron #
########

# Whether to enable cron. Set this to `true` or `false`, or pass a list of cron job *names* to enable
# (e.g. ['DNSManagerPoll']). Note that each cron job should only run on one server.
# View the list of available cron jobs in `../libraries/service_helper.rb`, under the `_all_crons` method.
default[:scalr_server][:cron][:enable] = true

############
# Services #
############

# The services to enable. Similarly to cron jobs, you should ensure each service only runs on one server. You can pass
# `true` to enable all services, `false` to disable all, or a list of *service names* to enable (e.g. ['images_cleanup']).
# Note that the plotter and the poller *must* run on the same host (and `rrd` — see below — must run on that host too).
# View the list of services that exist in `../libraries/service_helper.rb`, under the `_all_services` method.
default[:scalr_server][:service][:enable] = true

# Settings specific to the plotter. These should be configured to match what you configured in routing (if needed).
default[:scalr_server][:service][:plotter_bind_scheme] = 'http'
default[:scalr_server][:service][:plotter_bind_host] = '127.0.0.1'
default[:scalr_server][:service][:plotter_bind_port] = 6272


#######
# RRD #
#######

# Whether to enable rrd. You should do so on one server where you also run the plotter and poller services.
default[:scalr_server][:rrd][:enable] = true


##############
# Supervisor #
##############

# Whether to enable supervisor (the process manager for Scalr). You realistically shouldn't touch this, because without
# supervisor, nothing will run.
default[:scalr_server][:supervisor][:enable] = true

# The user to run supervisor as. Since supervisor su's to other users when running the processes above, using 'root'
# is pretty much what you're supposed to do here.
default[:scalr_server][:supervisor][:user] = 'root'



#########
# Other #
#########

# These are attributes from other cookbooks that are used throughout the installer. You shouldn't need to touch any of
# this.

# Attributes includes from other cookbooks. We need to include those because we refer to them in our own recipes,
# and don't want to have to ensure that those cookbooks are in the runlist to be able to use the attributes.
include_attribute  'rackspace_timezone'
include_attribute  'apparmor::apparmor'

# NTP cookbook configuration
default['ntp']['apparmor_enabled'] = false

# Supervisor configuration (there unfortunately is no better way to override it).
default['supervisor']['dir'] = "#{node.scalr_server.install_root}/etc/supervisor/conf.d"
default['supervisor']['conffile'] = "#{node.scalr_server.install_root}/etc/supervisor/supervisord.conf"

