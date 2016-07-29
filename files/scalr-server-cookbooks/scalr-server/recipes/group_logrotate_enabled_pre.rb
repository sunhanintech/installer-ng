directory etc_dir_for(node, 'logrotate') do
  description "Create directory (" + etc_dir_for(node, 'logrotate') + ")"
  owner 'root'
  group 'root'
  mode 0755
end

directory log_dir_for(node, 'logrotate') do
  description "Create directory (" + log_dir_for(node, 'logrotate') + ")"
  owner 'root'
  group 'root'
  mode 0755
end

directory data_dir_for(node, 'logrotate') do
  description "Create directory (" + data_dir_for(node, 'logrotate') + ")"
  owner 'root'
  group 'root'
  mode 0755
end

config = "#{etc_dir_for node, 'logrotate'}/config"

template config do
  description "Generate logrotate configuration (" + config + ")"
  source 'logrotate/config.erb'
  variables :keep_days => node[:scalr_server][:logrotate][:keep_days]
  owner 'root'
  group 'root'
  mode 0644
  helpers(Scalr::PathHelper)
end

template "#{etc_dir_for node, 'crond'}/cron.d/logrotate" do
  description "Generate cron entry for logrotate (" + "#{etc_dir_for node, 'crond'}/cron.d/logrotate" + ")"
  source 'logrotate/cron.erb'
  variables :conf => config
  owner 'root'
  group 'root'
  mode 0644
  notifies  :restart, 'supervisor_service[crond]' if service_is_up?(node, 'crond')
  helpers(Scalr::PathHelper)
end
