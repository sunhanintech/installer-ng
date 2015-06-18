supervisor_service 'nginx' do
  command         "#{node[:scalr_server][:install_root]}/embedded/sbin/nginx"
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/nginx.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/nginx.err"
  autostart       true
  startsecs       5
  action          [:enable, :start]
  subscribes      :restart, 'user[scalr_user]' if service_is_up?(node, 'nginx')
end
