# TODO - cron user.
# Create logging directory
directory "#{log_dir_for node, 'cron'}" do
  owner 'root'  # cron runs as root.
  mode 0755
  recursive true
end

# Create all the cron wrapper scripts (to set environment, etc.), and cron files.
directory "#{bin_dir_for node, 'cron'}" do
  owner 'root'  # cron runs as root.
  mode 0755
  recursive true
end

directory "#{etc_dir_for node, 'cron'}/cron.d" do
  owner 'root'  # cron runs as root.
  mode 0755
  recursive true
end

supervisor_service 'cron' do
  command         "#{node[:scalr_server][:install_root]}/embedded/sbin/crond" \
                  " -L #{log_dir_for node, 'cron'}/crond.log" \
                  " -s #{etc_dir_for node, 'cron'}/cron.d" \
                  ' -f'
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/crond.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/crond.err"
  action          [:enable, :start]
  autostart       true
end
