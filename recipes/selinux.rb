if File.directory?('/selinux')
  package value_for_platform_family(['rhel', 'fedora'] => 'policycoreutils-python', 'debian' => 'policycoreutils')

  selinux_disabled = 'sestatus | grep -qi disabled'

  execute "Allow httpd access to app path" do
    command lazy { "semanage fcontext -a -t httpd_sys_content_t '#{File.readlink(node[:scalr][:core][:location])}/app(/.*)?'" }
    not_if selinux_disabled
  end

  execute "Allow httpd access to cache path" do 
    command lazy { "semanage fcontext -a -t httpd_sys_content_t '#{File.readlink(node[:scalr][:core][:location])}/app/cache(/.*)?'" }
    not_if selinux_disabled
  end

  execute "Commit selinux changes" do
    command lazy { "restorecon -R #{File.readlink(node[:scalr][:core][:location])}/app/" }
    not_if selinux_disabled
  end

  execute "setsebool -P httpd_can_network_connect on" do
    not_if selinux_disabled
  end
end
