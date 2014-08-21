# Scalr attributes
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
default[:scalr][:deployment][:ssh_key_path] = ''
default[:scalr][:deployment][:ssh_key] = ''
default[:scalr][:deployment][:ssh_wrapper_path] = '/tmp/chef_ssh_deploy_wrapper'

# Useful locations for Scalr
default[:scalr][:core][:location] = File.join(node.scalr.package.deploy_to, 'current')
default[:scalr][:core][:configuration] = "#{node.scalr.core.location}/app/etc/config.yml"
default[:scalr][:core][:cryptokey_path] = "#{node[:scalr][:core][:location]}/app/etc/.cryptokey"

default[:scalr][:python][:venv] = "#{node.scalr.package.deploy_to}/venv"
default[:scalr][:python][:venv_path] = "#{node.scalr.python.venv}/bin:#{ENV['PATH']}" # Prioritize our Pythons!
default[:scalr][:python][:venv_python] = "#{node.scalr.python.venv}/bin/python"

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
default[:scalr][:services] = [
  {:service_name => 'msgsender', :service_module => 'msg_sender', :service_desc => 'Scalr Messaging Daemon', :service_extra_args => '', :run => {
    :daemon => true
  }},
  {:service_name => 'dbqueue', :service_module => 'dbqueue_event', :service_desc => 'Scalr DB Queue Event Poller', :service_extra_args => '', :run => {
    :daemon => true
  }},
  {:service_name => 'plotter', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Plotter', :service_extra_args => '--plotter', :run => {
    :daemon => true
  }},
  {:service_name => 'poller', :service_module => 'load_statistics', :service_desc => 'Scalr Load Stats Poller', :service_extra_args => '--poller', :run => {
    :daemon => true
  }},
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

# These new cron jobs were intoduced in 5.0
if Gem::Dependency.new(nil, '~> 5.0').match?(nil, node.scalr.package.version)
  extra_services = [
    {:service_name => 'szrupdater', :service_module => 'szr_upd_service', :service_desc => 'Scalarizr Update Client', :service_extra_args => '--interval=120', :run => {
      :daemon => true
    }},
    {:service_name => 'analytics_poller', :service_module => 'analytics_poller', :service_desc => 'Scalr Analytics Poller', :service_extra_args => '', :run => {
      :cron => {:hour => '*', :minute => '*/5'}
    }},
    {:service_name => 'analytics_processor', :service_module => 'analytics_processing', :service_desc => 'Scalr Analytics Processor', :service_extra_args => '', :run => {
      :cron => {:hour => '*', :minute => '7,37'}
    }},
  ]

  default[:scalr][:services].concat extra_services

  extra_crons = [
    {:hour => '*/12',  :minute => '0',    :ng => false,  :name => 'CloudPricing'},
    {:hour => '1',     :minute => '0',    :ng => false,  :name => 'AnalyticsNotifications'},
  ]

  default[:scalr][:crons].concat extra_crons

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
  # View here for package contents (extensions): https://webtatic.com/packages/php55/
  default['php']['packages'] = %w{php55w php55w-devel php55w-cli php55w-mysql php55w-mcrypt php55w-snmp php55w-process php55w-xml php55w-soap php55w-pear}
  default['php']['cnf_dirs'] = %w{/etc/php.d}

  default['apache']['extra_modules'] = %w{authz_owner}  # Modules that don't have a recipe.
when 'debian'
  # PHP
  # View here for package contents (extensions): http://ppa.launchpad.net/ondrej/php5/ubuntu/dists/precise/main/binary-amd64/Packages
  default['php']['packages'] = %w{php5 php5-dev php5-mysql php5-mcrypt php5-curl php5-snmp php-pear}
  default['php']['cnf_dirs'] = %w{/etc/php5/apache2/conf.d /etc/php5/cli/conf.d}
  default['php']['ext_conf_dir'] = '/etc/php5/mods-available'

  default['apache']['extra_modules'] = %w{authz_core authz_owner}
  default['apache']['pid_file']    = '/var/run/apache2/apache2.pid'
end

if node['platform'] == 'fedora' and node['platform_version'].to_f >= 19.0
  default['mysql']['client']['packages'] = %w[community-mysql community-mysql-devel]
end
