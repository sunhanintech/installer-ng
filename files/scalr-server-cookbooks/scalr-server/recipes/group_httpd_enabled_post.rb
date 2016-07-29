supervisor_service 'httpd' do
  description     "(Re)Start httpd service"
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/httpd" \
                  " -f #{etc_dir_for node, 'httpd'}/httpd.conf" \
                  ' -DFOREGROUND'
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/httpd.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/httpd.err"
  autostart       true
  startsecs       5
  action          [:enable, :start]
  subscribes      :restart, 'user[scalr_user]' if service_is_up?(node, 'httpd')
  subscribes      :restart, 'template[php_ini]' if service_is_up?(node, 'httpd')
  subscribes      :restart, 'template[ldap_conf]' if service_is_up?(node, 'httpd')
end
