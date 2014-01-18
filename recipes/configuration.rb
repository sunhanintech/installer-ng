template node[:scalr][:core][:configuration] do
  source "config.yml.erb"
  mode 0640
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end

template node[:scalr][:core][:log_configuration] do
  source "log4php.xml.erb"
  mode 0644
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end
