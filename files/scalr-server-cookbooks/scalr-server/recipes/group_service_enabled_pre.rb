# service directories
directory bin_dir_for(node, 'service') do
  owner     'root'
  group     'root'
  mode      0755
end

cookbook_file "#{bin_dir_for node, 'service'}/scalrpy_proxy" do
  owner     'root'
  group     'root'
  source    'scalrpy_proxy'
  mode    0755
end

directory run_dir_for(node, 'service') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'service') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory data_dir_for(node, 'service') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory "#{data_dir_for(node, 'service')}/graphics" do
  # This is where we serve stats graphics from
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end
