# rrd directories

directory run_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory data_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

%w{x1x6 x2x7 x3x8 x4x9 x5x0 journal}.each do |dir|
  directory "#{data_dir_for node, 'rrd'}/#{dir}" do
    owner     node[:scalr_server][:app][:user]
    group     node[:scalr_server][:app][:user]
    mode 0755
    recursive true
  end
end


# rrd run
supervisor_service 'rrd' do
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
