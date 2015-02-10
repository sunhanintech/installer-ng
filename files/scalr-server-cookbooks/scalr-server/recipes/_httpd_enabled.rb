# httpd directories

directory etc_dir_for(node, 'httpd') do
  owner     'root'
  group     'root'
  mode      0755
  recursive true
end

directory run_dir_for(node, 'httpd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'httpd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
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
  notifies  :restart, 'supervisor_service[httpd]' if service_is_up?(node, 'httpd')
end


# httpd run
# TODO - Consider reloading?
supervisor_service 'httpd' do
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/httpd" \
                  " -f #{etc_dir_for node, 'httpd'}/httpd.conf" \
                  ' -DFOREGROUND'
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/httpd.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/httpd.err"
  action          [:enable, :start]
  autostart       true
  startsecs       5
  subscribes      :restart, 'user[scalr_user]' if service_is_up?(node, 'httpd')
  subscribes      :restart, 'template[php_ini]' if service_is_up?(node, 'httpd')
end
