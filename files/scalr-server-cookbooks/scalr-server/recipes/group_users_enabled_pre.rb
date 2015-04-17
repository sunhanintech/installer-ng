user 'memcached_user' do
  username  node[:scalr_server][:memcached][:user]
  home      etc_dir_for(node, 'memcached')
  system    true
  notifies  :restart, 'supervisor_service[memcached]' if service_is_up?(node, 'memcached')
end

user 'scalr_user' do
  username  node[:scalr_server][:app][:user]
  home      "#{node[:scalr_server][:install_root]}/embedded/scalr"
  shell     '/bin/sh'  # TODO - Needed?
  system    true
end

user 'mysql_user' do
  username  node[:scalr_server][:mysql][:user]
  home      data_dir_for(node, 'mysql')  # TODO - Check if this works when it doesn't exist.
  system    true
end
