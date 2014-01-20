sysctl_file = '/etc/sysctl.d/100-scalr.conf'

template sysctl_file do
  source "sysctl-scalr.conf.erb"
  mode 0644
  owner 'root'
  group 'root'
end

service 'procps' do
  action :nothing
  subscribes :restart, "template[#{sysctl_file}]", :delayed
end
