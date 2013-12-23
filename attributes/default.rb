# Compile PHP from source, because packages.

# Scalr attributes
default[:scalr][:core][:group] = "scalr"
default[:scalr][:core][:users][:cron] = "root"
default[:scalr][:core][:users][:web] = value_for_platform_family('rhel' => 'apache', 'debian' => 'www-data')


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
when 'ubuntu'
  default['php']['packages'] = %W{php5 php5-dev php5-mysql php5-mcrypt php5-curl php5-snmp php-pear}
  default['php']['ext_conf_dir'] = '/etc/php5/mods-available'
end
