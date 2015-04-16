# TODO - cron user.
# Create logging directory
directory "#{log_dir_for node, 'cron'}" do
  owner 'root'  # cron runs as root.
  mode 0755
end

# Create all the cron wrapper scripts (to set environment, etc.), and cron files.
directory bin_dir_for(node, 'cron') do
  owner 'root'  # cron runs as root.
  mode 0755
end

directory etc_dir_for(node, 'cron') do
  owner 'root'  # cron runs as root.
  mode 0755
end

directory "#{etc_dir_for node, 'cron'}/cron.d" do
  owner 'root'  # cron runs as root.
  mode 0755
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
    notifies  :restart, 'supervisor_service[cron]' if service_is_up?(node, 'cron')
  end

  template "#{etc_dir_for node, 'cron'}/cron.d/#{cron[:name]}" do
    source   'cron/entry.erb'
    variables :cron => cron, :run_wrapper => run_wrapper
    mode      0644
    notifies  :restart, 'supervisor_service[cron]' if service_is_up?(node, 'cron')
  end
end
