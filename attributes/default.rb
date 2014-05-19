# Scalr attributes
default[:scalr][:core][:group] = 'scalr'
default[:scalr][:core][:users][:service] = 'root'
default[:scalr][:core][:users][:web] = value_for_platform_family('rhel' => 'apache', 'fedora' => 'apache', 'debian' => 'www-data')

#TODO -> Move to :deployment
default[:scalr][:package][:name] = 'scalr'
default[:scalr][:package][:revision] = 'HEAD'
default[:scalr][:package][:repo] = 'https://github.com/Scalr/scalr.git'
default[:scalr][:package][:deploy_to] = '/opt/scalr'
default[:scalr][:package][:release] = 'oss'  # oss | ee

default[:scalr][:is_enterprise] = node.scalr.package.release == 'ee'

# Only used if deploying from a private repo
default[:scalr][:deployment][:ssh_key_path] = ''
default[:scalr][:deployment][:ssh_key] = ''
default[:scalr][:deployment][:ssh_wrapper_path] = '/tmp/chef_ssh_deploy_wrapper'

# Useful locations for Scalr
default[:scalr][:core][:location] = File.join(node.scalr.package.deploy_to, 'current')
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

# Plotter settings #TODO: Deprecate when updating to 4.5
default[:scalr][:endpoint][:local_ip] = '127.0.0.1'
default[:scalr][:endpoint][:set_hostname] = false  # If you host can't resolve its IP to a name (gethostbyaddr fails), use this.

# Instance connection settings
default[:scalr][:instances_connection_policy] = 'auto'

# Load reporting settings
default[:scalr][:rrd][:rrd_dir] = '/var/lib/rrdcached/db'
default[:scalr][:rrd][:rrdcached_sock] = '/var/run/rrdcached.sock'
default[:scalr][:rrd][:img_url] = '/graphics'
default[:scalr][:rrd][:img_dir] = "#{node.scalr.core.location}/app/www#{node.scalr.rrd.img_url}"
default[:scalr][:rrd][:port] = 8080

# Scalr Daemon Attributes
default[:scalr][:daemons] = [
  {:daemon_name => 'msgsender', :daemon_module => 'msg_sender', :daemon_desc => 'Scalr Messaging Daemon', :daemon_extra_args => '' },
  {:daemon_name => 'dbqueue', :daemon_module => 'dbqueue_event', :daemon_desc => 'Scalr DB Queue Event Poller', :daemon_extra_args => '' },
  {:daemon_name => 'plotter', :daemon_module => 'load_statistics', :daemon_desc => 'Scalr Load Stats Plotter', :daemon_extra_args => '--plotter' },
  {:daemon_name => 'poller', :daemon_module => 'load_statistics', :daemon_desc => 'Scalr Load Stats Poller', :daemon_extra_args => '--poller' },
]

default[:scalr][:crons] = [
  {:hour => '*',    :minute => '*',    :ng => false, :name => 'Scheduler'},
  {:hour => '*',    :minute => '*/5',  :ng => false, :name => 'UsageStatsPoller'},
  {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Scaling'},
  {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'BundleTasksManager'},
  {:hour => '*',    :minute => '*/15', :ng => true,  :name => 'MetricCheck'},
  {:hour => '*',    :minute => '*/2',  :ng => true,  :name => 'Poller'},
  {:hour => '*',    :minute => '*',    :ng => false, :name => 'DNSManagerPoll'},
  {:hour => '*',    :minute => '*/2',  :ng => false, :name => 'EBSManager'},
  {:hour => '*',    :minute => '*/20', :ng => false, :name => 'RolesQueue'},
  {:hour => '*',    :minute => '*/5',  :ng => true,  :name => 'DbMsrMaintenance'},
  {:hour => '*',    :minute => '*/20', :ng => true,  :name => 'LeaseManager'},
  {:hour => '*',    :minute => '*',    :ng => true,  :name => 'ServerTerminate'},
  {:hour => '*/5',  :minute => '0',    :ng => true,  :name => 'RotateLogs'},
]

if node.scalr.is_enterprise
  default[:scalr][:daemons].push(
    {:daemon_name => 'szrupdater', :daemon_module => 'szr_upd_service', :daemon_desc => 'Scalarizr Update Client', :daemon_extra_args => '--interval=120' }
  )

  messaging_crons = %w{
    SzrMessagingAll SzrMessagingAll2
    SzrMessagingBeforeHostUp SzrMessagingBeforeHostUp2
    SzrMessagingHostInit SzrMessagingHostInit2
    SzrMessagingHostUp SzrMessagingHostUp2
  }
else
  messaging_crons = %w{SzrMessaging}
end

messaging_crons.each do |messaging_cron|
  default[:scalr][:crons].push({:hour => '*', :minute => '*/2', :ng => false, :name => messaging_cron})
end


# Time attributes
default['tz'] = 'UTC'

# PHP attributes
include_attribute 'php'

default['php']['version'] = '5.5.7'
default['php']['install_method'] = 'package'


# Apache attributes
default['apache']['default_modules'] = %w{
  alias autoindex deflate dir env filter headers mime negotiation php5 rewrite
  setenvif status log_config logio
  authz_host authz_user
}

case node['platform_family']
when 'rhel', 'fedora'
  # PHP
  default['php']['packages'] = %w{php php-devel php-cli php-mysql php-mcrypt php-snmp php-process php-dom php-soap php-pear}
  default['php']['cnf_dirs'] = %w{/etc/php.d}

  default['apache']['extra_modules'] = %w{authz_owner}  # Modules that don't have a recipe.
when 'debian'
  # PHP
  default['php']['packages'] = %w{php5 php5-dev php5-mysql php5-mcrypt php5-curl php5-snmp php-pear}
  default['php']['cnf_dirs'] = %w{/etc/php5/apache2/conf.d /etc/php5/cli/conf.d}
  default['php']['ext_conf_dir'] = '/etc/php5/mods-available'

  default['apache']['extra_modules'] = %w{authz_core authz_owner}
  default['apache']['pid_file']    = '/var/run/apache2/apache2.pid'
end

if node['platform'] == 'fedora' and node['platform_version'].to_f >= 19.0
  default['mysql']['client']['packages'] = %w[community-mysql community-mysql-devel]
end
