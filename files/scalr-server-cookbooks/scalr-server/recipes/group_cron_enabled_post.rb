supervisor_service 'cron' do
  command         "#{node[:scalr_server][:install_root]}/embedded/sbin/crond" \
                  " -L #{log_dir_for node, 'cron'}/crond.log" \
                  " -s #{etc_dir_for node, 'cron'}/cron.d" \
                  ' -f'
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/crond.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/crond.err"
  autostart       true
  action          [:enable, :start]
end
