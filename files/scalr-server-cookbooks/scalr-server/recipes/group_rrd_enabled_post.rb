supervisor_service 'rrd' do
  description     "(Re)Start rrd service"
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/rrdcached" \
                  " -s #{node[:scalr_server][:app][:user]}" \
                  " -l unix:#{run_dir_for node, 'rrd'}/rrdcached.sock" \
                  " -p #{run_dir_for node, 'rrd'}/rrdcached.pid" \
                  " -j #{data_dir_for node, 'rrd'}/journal -F" \
                  " -b #{data_dir_for node, 'rrd'} -B" \
                  ' -g'
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/rrd.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/rrd.err"
  user            node[:scalr_server][:app][:user]
  action          [:enable, :start]
  autostart       true
  subscribes      :restart, 'user[scalr_user]' if service_is_up?(node, 'rrd')
end
