# Scalr attributes
default[:scalr][:core][:group] = 'scalr'
default[:scalr][:core][:users][:web] = value_for_platform_family('rhel' => 'apache', 'fedora' => 'apache', 'debian' => 'www-data')
default[:scalr][:core][:users][:service] = 'root'

default[:scalr][:core][:package][:name] = 'scalr'
default[:scalr][:core][:package][:version] = '4.5.1'
default[:scalr][:core][:package][:checksum] = '3c0323acd0fbcbd151a9f1879b0a703976ec7d0a73e00d0804e44fa89797f8ba'
default[:scalr][:core][:package][:url] = "https://github.com/Scalr/scalr/archive/v#{node.scalr.core.package.version}.tar.gz"
default[:scalr][:core][:package][:deploy_to] = '/opt/scalr'

default[:scalr][:core][:location] = File.join(node.scalr.core.package.deploy_to, 'current',
                                              "#{node.scalr.core.package.name}-#{node.scalr.core.package.version}")

# This isn't really configurable.. is that the right way to do it?
default[:scalr][:core][:configuration] = "#{node.scalr.core.location}/app/etc/config.yml"
default[:scalr][:core][:log_configuration] = "#{node.scalr.core.location}/app/etc/log4php.xml"

default[:scalr][:core][:log_dir] = '/var/log/scalr'
default[:scalr][:core][:pid_dir] = '/var/run/scalr'

# User settings
default[:scalr][:admin][:username] = 'admin'
default[:scalr][:admin][:password] = 'scalr'

# Database settings
default[:scalr][:database][:username] = 'scalr'
default[:scalr][:database][:password] = 'scalr'
default[:scalr][:database][:dbname] = 'scalr'
default[:scalr][:database][:host] = 'localhost'
default[:scalr][:database][:port] = 3306

default[:scalr][:database][:client_host] = 'localhost'  # Where will the client connect from?
default['mysql']['bind_address'] = 'localhost'

# Email settings
default[:scalr][:email][:from] = 'scalr@scalr.example.com'
default[:scalr][:email][:name] = 'Scalr Service'

# Host settings
default[:scalr][:endpoint][:scheme] = 'http'
default[:scalr][:endpoint][:host_ip] = '127.0.0.1'
default[:scalr][:endpoint][:host] = node.scalr.endpoint.host_ip

# Hostname
default[:scalr][:endpoint][:set_hostname] = false  # If you host can't resolve its IP to a name (gethostbyaddr fails), use this.

# Instance connection settings
default[:scalr][:instances_connection_policy] = 'auto'

# Load reporting settings
default[:scalr][:rrd][:rrd_dir] = '/var/lib/rrdcached/db'
default[:scalr][:rrd][:img_dir] = "#{node.scalr.core.location}/app/www/graphics"
default[:scalr][:rrd][:img_url] = '/graphics'
default[:scalr][:rrd][:port] = 8080

# PHP attributes
include_attribute 'php'

default['php']['version'] = '5.5.7'
default['php']['install_method'] = 'package'
default['php']['directives'] = {
  :disable_functions => '',
  :short_open_tags => 'On',
  :safe_mode => 'Off',
  :register_gloabls => 'Off'
}  #TODO: Does not work!

case node['platform']
when 'redhat', 'centos', 'fedora'
  default['php']['packages'] = %w{php php-devel php-cli php-mysql php-mcrypt php-snmp php-process php-dom php-soap php-pear}
  default['php']['cnf_dirs'] = %w{/etc/php.d}
when 'ubuntu'
  default['php']['packages'] = %w{php5 php5-dev php5-mysql php5-mcrypt php5-curl php5-snmp php-pear}
  default['php']['cnf_dirs'] = %w{/etc/php5/apache2/conf.d /etc/php5/cli/conf.d}
  default['php']['ext_conf_dir'] = '/etc/php5/mods-available'
end


if node['platform'] == 'fedora' and node['platform_version'].to_f >= 19.0
  default['mysql']['client']['packages'] = %w[community-mysql community-mysql-devel]
end

# Apache attributes
default['apache']['default_modules'] = %w{status alias autoindex dir env mime negotiation setenvif}
