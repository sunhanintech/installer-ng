# https://code.google.com/p/memcached/wiki/ReleaseNotes145
supervisor_service 'memcached' do
  description     "Start memcached service"
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/memcached" \
                  " -l #{node[:scalr_server][:memcached][:bind_host]}" \
                  " -p #{node[:scalr_server][:memcached][:bind_port]}" \
                  " -u #{node[:scalr_server][:memcached][:user]}" +
                      (memcached_enable_sasl?(node) ? ' -S' : '')
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/memcached.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/memcached.err"
  autostart       true
  action          [:enable, :start]
end
