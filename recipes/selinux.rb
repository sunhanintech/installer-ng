if File.directory?('/selinux')
  app_path = "#{node[:scalr][:core][:location]}/app"
  cache_path = "#{app_path}/cache"

  package 'policycoreutils-python'
  execute "semanage fcontext -a -t httpd_sys_content_t '#{app_path}(/.*)?'"
  execute "semanage fcontext -a -t httpd_sys_rw_content_t '#{cache_path}(/.*)?'"
  execute "restorecon -R #{app_path}/"
  execute "setsebool -P httpd_can_network_connect on"
end
