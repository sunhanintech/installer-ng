template node[:scalr][:core][:configuration] do
  source "config.yml.erb"
  mode 640
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end
