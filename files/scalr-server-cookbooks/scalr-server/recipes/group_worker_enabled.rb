# Worker directories

directory run_dir_for(node, 'worker') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'worker') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end


# Actually launch the workers

enabled_services(node).each do |svc|
  # Make sure we're only dealing with symbols here (recursively)
  HashHelper.symbolize_keys_deep!(svc)

  # TODO - Reload every time we run (because if someone's running reconfigure, it's for a purpose!)
  supervisor_service "worker-#{svc[:service_name]}" do
    command         "#{node[:scalr_server][:install_root]}/embedded/bin/python" \
                    " #{scalr_bundle_path node}/app/python/scalrpy/#{svc[:service_module]}.py" \
                    " --pid-file=#{run_dir_for node, 'worker'}/#{svc[:service_name]}.pid" \
                    " --log-file=#{log_dir_for node, 'worker'}/#{svc[:service_name]}.log" \
                    " --user=#{node[:scalr_server][:app][:user]}" \
                    " --group=#{node[:scalr_server][:app][:user]}" \
                    " --config=#{scalr_bundle_path node}/app/etc/config.yml" \
                    ' --verbosity=INFO' \
                    " #{svc[:service_extra_args]}" \
                    ' start'
    stdout_logfile  "#{log_dir_for node, 'supervisor'}/worker-#{svc[:service_name]}.log"
    stderr_logfile  "#{log_dir_for node, 'supervisor'}/worker-#{svc[:service_name]}.err"
    action          [:enable, :start]
    autostart       true
    subscribes      :restart, 'template[scalr_config]', :delayed
    subscribes      :restart, 'file[scalr_cryptokey]', :delayed
    subscribes      :restart, 'file[scalr_id]', :delayed
  end
end
