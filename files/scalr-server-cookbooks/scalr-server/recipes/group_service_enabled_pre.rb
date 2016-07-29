# service directories
directory bin_dir_for(node, 'service') do
  description "Create directory (" + bin_dir_for(node, 'service') + ")"
  owner     'root'
  group     'root'
  mode      0755
end

cookbook_file "#{bin_dir_for node, 'service'}/scalrpy_proxy" do
  description "(Re)Start Scalr python proxy"
  owner     'root'
  group     'root'
  source    'scalrpy_proxy'
  mode    0755
end

directory run_dir_for(node, 'service') do
  description "Create directory (" + run_dir_for(node, 'service') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory log_dir_for(node, 'service') do
  description "Create directory (" + log_dir_for(node, 'service') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory data_dir_for(node, 'service') do
  description "Create directory (" + data_dir_for(node, 'service') + ")"
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end

directory "#{data_dir_for(node, 'service')}/graphics" do
  description "Create directory (" + "#{data_dir_for(node, 'service')}/graphics" + ")"
  # This is where we serve stats graphics from
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
end
