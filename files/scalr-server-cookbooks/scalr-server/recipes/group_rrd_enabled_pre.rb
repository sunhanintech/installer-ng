# rrd directories

directory run_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory data_dir_for(node, 'rrd') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

%w{x1x6 x2x7 x3x8 x4x9 x5x0 journal}.each do |dir|
  directory "#{data_dir_for node, 'rrd'}/#{dir}" do
    owner     node[:scalr_server][:app][:user]
    group     node[:scalr_server][:app][:user]
    mode 0755
  end
end
