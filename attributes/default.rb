# Scalr attributes
default[:scalr][:core][:group] = 'scalr'
default[:scalr][:core][:users][:web] = value_for_platform_family('rhel' => 'apache', 'debian' => 'www-data')
default[:scalr][:core][:users][:service] = 'root'

default[:scalr][:core][:package][:name] = 'scalr'
default[:scalr][:core][:package][:version] = '4.5.1'
default[:scalr][:core][:package][:checksum] = '3c0323acd0fbcbd151a9f1879b0a703976ec7d0a73e00d0804e44fa89797f8ba'
default[:scalr][:core][:package][:url] = "https://github.com/Scalr/scalr/archive/v#{default[:scalr][:core][:package][:version]}.tar.gz"
default[:scalr][:core][:package][:deploy_to] = '/opt/scalr'

default[:scalr][:core][:location] = File.join(default[:scalr][:core][:package][:deploy_to], 'current',
                                              "#{default[:scalr][:core][:package][:name]}-#{default[:scalr][:core][:package][:version]}")

default[:scalr][:core][:configuration] = "#{default[:scalr][:core][:location]}/app/etc/config.yml" # This isn't really configurable.. is that the right way to do it?

default[:scalr][:core][:log_dir] = '/var/log/scalr'
default[:scalr][:core][:pid_dir] = '/var/run/scalr'

# Database settings
default[:scalr][:database][:username] = 'scalr'
default[:scalr][:database][:password] = 'scalr'
default[:scalr][:database][:dbname] = 'scalr'
default[:scalr][:database][:client_host] = 'localhost'

default[:scalr][:database][:host] = 'localhost'
default[:scalr][:database][:port] = 3306


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
when 'redhat', 'centos'
  default['php']['packages'] = %W{php php-devel php-cli php-mysql php-mcrypt php-snmp php-process php-dom php-soap php-pear}
  default['php']['cnf_dirs'] = %W{/etc/php.d}
when 'ubuntu'
  default['php']['packages'] = %W{php5 php5-dev php5-mysql php5-mcrypt php5-curl php5-snmp php-pear}
  default['php']['cnf_dirs'] = %W{/etc/php5/apache2/conf.d /etc/php5/cli/conf.d}
  default['php']['ext_conf_dir'] = '/etc/php5/mods-available'
end


# Apache attributes
default['apache']['default_modules'] = %w{status alias autoindex dir env mime negotiation setenvif}
