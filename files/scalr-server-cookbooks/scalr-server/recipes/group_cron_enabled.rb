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

php = "#{node[:scalr_server][:install_root]}/embedded/bin/php -c #{etc_dir_for node, 'php'} -q"
og_cmd = "#{php} #{node[:scalr_server][:install_root]}/embedded/scalr/app/cron/cron.php"
ng_cmd = "#{php} #{node[:scalr_server][:install_root]}/embedded/scalr/app/cron-ng/cron.php"

enabled_crons(node).each do |cron|
  cmd = cron[:ng] ? ng_cmd : og_cmd

  run_wrapper = "#{bin_dir_for node, 'cron'}/#{cron[:name]}"

  template run_wrapper do
    source    'cron/wrapper.erb'
    variables :cmd => cmd, :path => scalr_exec_path(node), :cron => cron
    mode      0755
    helpers(Scalr::PathHelper)
    notifies  :restart, 'supervisor_service[cron]' if should_notify_service?('cron')
  end

  template "#{etc_dir_for node, 'cron'}/cron.d/#{cron[:name]}" do
    source   'cron/entry.erb'
    variables :cron => cron, :run_wrapper => run_wrapper
    mode      0644
    notifies  :restart, 'supervisor_service[cron]' if should_notify_service?('cron')
  end
end

# TODO - As long as we have the old "cron daemons", we can't really restart the daemons when the and Scalr config changes.
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

# TODO check TZ cron is running in.
