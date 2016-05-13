# httpd directories

directory etc_dir_for(node, 'httpd') do
  description "Create directory (" + etc_dir_for(node, 'httpd') + ")"
  owner     'root'
  group     'root'
  mode      0755
end

directory run_dir_for(node, 'httpd') do
  description "Create directory (" + run_dir_for(node, 'httpd') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'httpd') do
  description "Create directory (" + log_dir_for(node, 'httpd') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end


# httpd configuration

template "#{etc_dir_for node, 'httpd'}/httpd.conf" do
  description "Generate httpd configuration (" + "#{etc_dir_for node, 'httpd'}/httpd.conf" + ")"
  source    'httpd/httpd.conf.erb'
  owner     'root'
  group     'root'
  mode      0644
  helpers do
    include Scalr::PathHelper
    include Scalr::ServiceHelper
  end
  notifies  :restart, 'supervisor_service[httpd]' if service_is_up?(node, 'httpd')
end
