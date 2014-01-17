[node[:scalr][:rrd][:rrd_dir], '/var/lib/rrdcached/journal'].each do |dir|
  directory dir do
    owner node[:scalr][:core][:users][:service]
    group node[:scalr][:core][:group]
    notifies :restart, "service[rrdcached]", :delayed
    recursive true
  end
end

package 'rrdcached'

service 'rrdcached' do
  action :nothing
  subscribes :restart, "template[/etc/default/rrdcached]", :delayed
end

template "/etc/default/rrdcached" do
  source "rrdcached.erb"
end

%W{x1x6 x2x7 x3x8 x4x9 x5x0}.each do |dir|
  directory "#{node[:scalr][:rrd][:rrd_dir]}/#{dir}" do
    owner node[:scalr][:core][:users][:service]
    group node[:scalr][:core][:group]
    mode 0755
    action :create
    notifies :restart, "service[rrdcached]", :delayed
  end
end
