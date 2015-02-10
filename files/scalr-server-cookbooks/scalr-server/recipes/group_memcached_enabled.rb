user 'memcached_user' do
  username  node[:scalr_server][:memcached][:user]
  home      etc_dir_for(node, 'memcached')
  system    true
end

bash 'set_memcached_password' do
  code  <<-EOH
  printf "%s" "#{node[:scalr_server][:memcached][:password]}" | /opt/scalr-server/embedded/sbin/saslpasswd2 \
  -a memcached \
  -c #{node[:scalr_server][:memcached][:username]} \
  -p
  EOH
end

file "#{node[:scalr_server][:install_root]}/embedded/etc/sasldb2" do
  mode    0644  # Needs to be readable by memcached
  action :touch
end

cookbook_file "#{node[:scalr_server][:install_root]}/embedded/lib/sasl2/memcached.conf" do
  source    'memcached/memcached.conf'
  owner     'root'
  group     'root'
  mode      0644
end

# https://code.google.com/p/memcached/wiki/ReleaseNotes145

supervisor_service 'memcached' do
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/memcached" \
                  " -l #{node[:scalr_server][:memcached][:bind_host]}" \
                  " -p #{node[:scalr_server][:memcached][:bind_port]}" \
                  ' -S -vvv'
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/memcached.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/memcached.err"
  user            node[:scalr_server][:memcached][:user]
  autostart       true
  action          [:enable, :start]
  subscribes      :restart, 'user[scalr_user]' if service_is_up?(node, 'memcached')
end
