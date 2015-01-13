# Add rrd user
user node[:scalr_server][:rrd][:user] do
  home   data_dir_for(node, 'rrd')
  system true
end


# Add app user to group, so they can write to the rrdcached socket.
group node[:scalr_server][:rrd][:user] do
  append    true
  members   [node[:scalr_server][:app][:user]]
end


# rrd directories

directory run_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:rrd][:user]
  group     node[:scalr_server][:rrd][:user]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:rrd][:user]
  group     node[:scalr_server][:rrd][:user]
  mode      0755
  recursive true
end

directory data_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:rrd][:user]
  group     node[:scalr_server][:rrd][:user]
  mode      0755
  recursive true
end

%w{x1x6 x2x7 x3x8 x4x9 x5x0 journal}.each do |dir|
  directory "#{data_dir_for node, 'rrd'}/#{dir}" do
    owner     node[:scalr_server][:rrd][:user]
    group     node[:scalr_server][:rrd][:user]
    mode 0755
    recursive true
  end
end


# rrd run
# TODO - Consider reloading?
supervisor_service 'rrd' do
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/rrdcached" \
                  " -s #{node[:scalr_server][:rrd][:user]}" \
                  " -l unix:#{run_dir_for node, 'rrd'}/rrdcached.sock" \
                  " -p #{run_dir_for node, 'rrd'}/rrdcached.pid" \
                  " -j #{data_dir_for node, 'rrd'}/journal -F" \
                  " -b #{data_dir_for node, 'rrd'} -B" \
                  ' -g'
  stdout_logfile  "#{log_dir_for node, 'supervisor'}/rrd.log"
  stderr_logfile  "#{log_dir_for node, 'supervisor'}/rrd.err"
  user            node[:scalr_server][:rrd][:user]
  action          [:enable, :start]
  autostart       true
end
