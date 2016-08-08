# nginx directories

directory etc_dir_for(node, 'nginx') do
  description "Create directory (" + etc_dir_for(node, 'nginx') + ")"
  owner     'root'
  group     'root'
  mode      0755
end

directory run_dir_for(node, 'nginx') do
  description "Create directory (" + run_dir_for(node, 'nginx') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory data_dir_for(node, 'nginx') do
  description "Create directory (" + data_dir_for(node, 'nginx') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'nginx') do
  description "Create directory (" + log_dir_for(node, 'nginx') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end


# nginx configuration

template "#{etc_dir_for node, 'nginx'}/nginx.conf" do
  description "Generate nginx configuration (" + "#{etc_dir_for node, 'nginx'}/nginx.conf" + ")"
  source    'nginx/nginx.conf.erb'
  owner     'root'
  group     'root'
  mode      0644
  variables :cores => Mixlib::ShellOut.new('cat /proc/cpuinfo | grep processor | wc -l').run_command.stdout.to_i
  helpers do
    include Scalr::PathHelper
    include Scalr::ServiceHelper
  end
  notifies  :restart, 'supervisor_service[httpd]', :immediately if service_is_up?(node, 'httpd')
  notifies  :restart, 'supervisor_service[nginx]' if service_is_up?(node, 'nginx')
end

template "#{etc_dir_for node, 'nginx'}/locations.conf" do
  description "Generate vhost configuration (" + "#{etc_dir_for node, 'nginx'}/locations.conf" + ")"
  source    'nginx/locations.conf.erb'
  owner     'root'
  group     'root'
  mode      0644
  notifies  :restart, 'supervisor_service[httpd]', :immediately if service_is_up?(node, 'httpd')
  notifies  :restart, 'supervisor_service[nginx]' if service_is_up?(node, 'nginx')
end

template "#{etc_dir_for node, 'nginx'}/mime.types" do
  description "Generate mime types (" + "#{etc_dir_for node, 'nginx'}/mime.types" + ")"
  source    'nginx/mime.types.erb'
  owner     'root'
  group     'root'
  mode      0644
  notifies  :restart, 'supervisor_service[httpd]', :immediately if service_is_up?(node, 'httpd')
  notifies  :restart, 'supervisor_service[nginx]' if service_is_up?(node, 'nginx')
end

