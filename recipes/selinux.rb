if File.directory?('/selinux')
  app_path = "#{node[:scalr][:core][:location]}/app"
  cache_path = "#{app_path}/cache"

  package value_for_platform_family(['rhel', 'fedora'] => 'policycoreutils-python', 'debian' => 'policycoreutils')

  selinux_disabled = 'sestatus | grep -qi disabled'

  execute "semanage fcontext -a -t httpd_sys_content_t '#{app_path}(/.*)?'" do
    not_if selinux_disabled
  end

  execute "semanage fcontext -a -t httpd_sys_rw_content_t '#{cache_path}(/.*)?'" do
    not_if selinux_disabled
  end

  execute "restorecon -R #{app_path}/" do
    not_if selinux_disabled
  end

  execute "setsebool -P httpd_can_network_connect on" do
    not_if selinux_disabled
  end
end
