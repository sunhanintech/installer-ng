php = "#{node[:scalr_server][:install_root]}/embedded/bin/php -c #{etc_dir_for node, 'php'} -q"
og_cmd = "#{php} #{node[:scalr_server][:install_root]}/embedded/scalr/app/cron/cron.php"
ng_cmd = "#{php} #{node[:scalr_server][:install_root]}/embedded/scalr/app/cron-ng/cron.php"

enabled_crons(node).each do |cron|
  cmd = cron[:ng] ? ng_cmd : og_cmd

  run_wrapper = "#{bin_dir_for node, 'crond'}/#{cron[:name]}"

  template run_wrapper do
    source    'cron/wrapper.erb'
    variables :cmd => cmd, :path => scalr_exec_path(node), :cron => cron
    mode      0755
    helpers(Scalr::PathHelper)
    notifies  :restart, 'supervisor_service[crond]' if service_is_up?(node, 'crond')
  end

  template "#{etc_dir_for node, 'crond'}/cron.d/#{cron[:name]}" do
    source   'cron/entry.erb'
    variables :cron => cron, :run_wrapper => run_wrapper
    mode      0644
    notifies  :restart, 'supervisor_service[crond]' if service_is_up?(node, 'crond')
  end
end

