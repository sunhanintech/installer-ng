# httpd directories

directory etc_dir_for(node, 'httpd') do
  owner     'root'
  group     'root'
  mode      0755
end

directory run_dir_for(node, 'httpd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'httpd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end


# httpd configuration

template "#{etc_dir_for node, 'httpd'}/httpd.conf" do
  source    'httpd/httpd.conf.erb'
  owner     'root'
  group     'root'
  mode      0644
  helpers do
    include Scalr::PathHelper
    include Scalr::ServiceHelper
  end
  notifies  :restart, 'supervisor_service[httpd]', :immediately if service_is_up?(node, 'httpd')
end
