# Install Monit to watch over our daemons
package 'monit'

service 'monit' do
  action [:enable, :start]
end

case node[:platform_family]
when 'rhel', 'fedora'
  monit_dir = '/etc/monit.d'
when 'debian'
  monit_dir = '/etc/monit/conf.d'
end

directory monit_dir do
  owner 'root'
  group 'root'
  mode  0644
end

cookbook_file "#{monit_dir}/daemon" do
  owner     'root'
  group     'root'
  mode      0644
  source    'monit-daemon'
  notifies  :restart, 'service[monit]', :delayed
end

# Install LSB scripts - we use them in the services
if node[:platform_family] == 'fedora'
  package 'redhat-lsb'
end


enabled_services(node).each do |svc|
  # Make sure we're only dealing with symbols here (recursively)
  HashHelper.symbolize_keys_deep!(svc)

  svc[:piddir] = node[:scalr][:core][:pid_dir]
  svc[:pidfile] = "#{node[:scalr][:core][:pid_dir]}/#{svc[:service_name]}.pid"
  svc[:logfile] = "#{node[:scalr][:core][:log_dir]}/#{svc[:service_name]}.log"
  svc[:user] = node[:scalr][:core][:users][:service]
  svc[:group] = node[:scalr][:core][:group]

  init_file = "/etc/init.d/#{svc[:service_name]}"

  template init_file do
    source "#{node[:platform_family]}-init-service.erb"
    mode 0755
    owner "root"
    group "root"
    variables svc
    helpers do
      include Scalr::VersionHelper
      include Scalr::PathHelper
    end
  end

  action = if svc[:run][:daemon] then [:enable, :start] else [:nothing] end
  log "Action for #{svc[:service_name]}: #{action}"

  service svc[:service_name] do
    supports   :restart => true
    subscribes :restart, "template[#{init_file}]", :delayed
    subscribes :restart, "template[#{node[:scalr][:core][:configuration]}]", :delayed
    subscribes :restart, "execute[Mark Install]", :delayed
    subscribes :restart, "ruby_block[Set Endpoint Hostname]", :delayed
    subscribes :restart, "deploy_revision[#{node[:scalr][:package][:name]}]", :delayed
    action     action
  end

  # Monit

  if svc[:run][:daemon]
    template "#{monit_dir}/#{svc[:service_name]}" do
      source    'monit-service.erb'
      mode       0644
      owner     'root'
      group     'root'
      variables svc
      notifies  :restart, 'service[monit]', :delayed
    end
  end

  # Crontab
  if svc[:run][:cron]
    cron_d svc[:service_name] do
      hour    svc[:run][:cron][:hour]
      minute  svc[:run][:cron][:minute]
      user    node[:scalr][:core][:users][:service]
      path    node[:scalr][:cron][:path]
      command "/usr/bin/env service #{svc[:service_name]} start"
    end
  end
end
