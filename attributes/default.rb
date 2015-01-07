# Scalr attributes
default[:scalr][:id] ='unset'

# Users
default[:scalr][:core][:group] = 'scalr'
default[:scalr][:core][:users][:service] = 'root'
default[:scalr][:core][:users][:web] = value_for_platform_family('rhel' => 'apache', 'fedora' => 'apache', 'debian' => 'www-data')

#TODO -> Move to :deployment
default[:scalr][:package][:name] = 'scalr'
default[:scalr][:package][:revision] = 'HEAD'
default[:scalr][:package][:repo] = 'https://github.com/Scalr/scalr.git'
default[:scalr][:package][:deploy_to] = '/opt/scalr'

default[:scalr][:package][:version] = '4.5.0'
default[:scalr][:package][:version_obj] = Gem::Version.new(node.scalr.package.version)

# Only used if deploying from a private repo
default[:scalr][:deployment][:ssh_key] = ''

# Useful locations for Scalr
default[:scalr][:core][:location] = File.join(node.scalr.package.deploy_to, 'current')
default[:scalr][:core][:configuration] = "#{node.scalr.core.location}/app/etc/config.yml"
default[:scalr][:core][:cryptokey_path] = "#{node[:scalr][:core][:location]}/app/etc/.cryptokey"
default[:scalr][:core][:id_path] = "#{node[:scalr][:core][:location]}/app/etc/id"

default[:scalr][:python][:venv] = "#{node.scalr.package.deploy_to}/venv"

default[:scalr][:python][:venv_force_install] = [['httplib2', nil], ['pymysql', nil], ['cherrypy', '3.2.6'], ['pytz', nil]]

# Misc dirs
default[:scalr][:core][:log_dir] = '/var/log/scalr'
default[:scalr][:core][:pid_dir] = '/var/run/scalr'

# User settings
default[:scalr][:admin][:username] = 'admin'
default[:scalr][:admin][:password] = 'scalr'

# Database settings
default[:scalr][:database][:username] = 'scalr'
default[:scalr][:database][:password] = 'scalr'
default[:scalr][:database][:host] = 'localhost'
default[:scalr][:database][:port] = 3306
default[:scalr][:database][:scalr_dbname] = 'scalr'
default[:scalr][:database][:analytics_dbname] = 'analytics'

default[:scalr][:database][:client_host] = 'localhost'  # Where will the client connect from?

# Email settings
default[:scalr][:email][:from] = 'scalr@scalr.example.com'
default[:scalr][:email][:name] = 'Scalr Service'

# Host settings
default[:scalr][:endpoint][:scheme] = 'http'
default[:scalr][:endpoint][:host_ip] = '127.0.0.1'
default[:scalr][:endpoint][:host] = node.scalr.endpoint.host_ip

# Deprecated since 4.5
default[:scalr][:endpoint][:local_ip] = '127.0.0.1'
default[:scalr][:endpoint][:set_hostname] = false  # If you host can't resolve its IP to a name (gethostbyaddr fails), use this.

# Instance connection settings
default[:scalr][:instances_connection_policy] = 'auto'

# Load reporting settings
default[:scalr][:rrd][:rrd_dir] = '/var/lib/rrdcached/db'
default[:scalr][:rrd][:journal_dir] = '/var/lib/rrdcached/journal'
default[:scalr][:rrd][:run_dir] = value_for_platform_family(
  %w(rhel fedora) => '/var/rrdtool/rrdcached',
  'debian' => '/var/run'
)
# ^^ Don't change this. Scalrpy somehow wants rrdcached.pid to be found in this
# run_dir. Unfortunately, neither Ubuntu nor Debian let us specify this, so instead
# of pointing rrd at the right directory, we point Scalrpy to it.
default[:scalr][:rrd][:img_url] = '/graphics'
default[:scalr][:rrd][:img_dir] = "#{node.scalr.core.location}/app/www#{node.scalr.rrd.img_url}"
default[:scalr][:rrd][:port] = 8080


# Cron jobs
default[:scalr][:cron][:path] = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'


# PHP attributes
default['php']['version'] = '5.5.7'
default['php']['install_method'] = 'package'

case node['platform_family']
when 'rhel', 'fedora'
  # View here for package contents (extensions): https://webtatic.com/packages/php55/
  default['php']['packages'] = %w{php55w php55w-devel php55w-cli php55w-mysql php55w-mcrypt php55w-snmp php55w-process php55w-xml php55w-soap php55w-pear}
  default['php']['cnf_dirs'] = %w{/etc/php.d}
when 'debian'
  # View here for package contents (extensions): http://ppa.launchpad.net/ondrej/php5/ubuntu/dists/precise/main/binary-amd64/Packages
  default['php']['packages'] = %w{php5 php5-dev php5-mysql php5-mcrypt php5-curl php5-snmp php-pear}
  default['php']['cnf_dirs'] = %w{/etc/php5/apache2/conf.d /etc/php5/cli/conf.d}
  default['php']['ext_conf_dir'] = '/etc/php5/mods-available'
end

default['php']['session_save_path'] = '/var/lib/scalr/sessions'


# Apache attributes
default['apache']['user'] = node.scalr.core.users.web
default['apache']['group'] = node.scalr.core.group
default['apache']['mpm'] = 'prefork'  # For mod_php
default['apache']['extra_modules'] = %w{rewrite deflate filter headers php5 authz_owner}

if node['platform_family'] == 'debian'
  # The debphp PPA we use ships Apache 2.4. These are the attributes the Apache 2 Cookbook for Apache 2.4.
  # We have to *all* of those here (not just the version), because they are defined based on the
  # apache/version attribute in the Apache 2 Cookbook.
  default['apache']['version'] = '2.4'
  default['apache']['pid_file']    = '/var/run/apache2/apache2.pid'
  default['apache']['docroot_dir'] = '/var/www/html'
end

if node['apache']['version'] == '2.4'
  # Our Scalr virtualhost uses Apache 2.2-style rules here
  default['apache']['extra_modules'].push 'access_compat'
end

# Override for a bug in yum-mysql-community cookbook (that ignores RHEL 7)
# TODO - probably doesn't need to be an override here
override['yum']['mysql55-community']['baseurl'] = "http://repo.mysql.com/yum/mysql-5.5-community/el/#{node['platform_version'].to_i}/$basearch/"

