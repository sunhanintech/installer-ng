# service directories
directory bin_dir_for(node, 'service') do
  owner     'root'
  group     'root'
  mode      0755
  recursive true
end

cookbook_file "#{bin_dir_for node, 'service'}/scalrpy_proxy" do
  owner     'root'
  group     'root'
  source 'scalrpy_proxy'
  mode    0755
end

directory run_dir_for(node, 'service') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory log_dir_for(node, 'service') do
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end

directory "#{data_dir_for(node, 'service')}/graphics" do
  # This is wher we serve stats graphics from
  owner     node[:scalr_server][:app][:user]
  group     node[:scalr_server][:app][:user]
  mode      0755
  recursive true
end


# Actually launch the services

enabled_services(node).each do |svc|
  # Make sure we're only dealing with symbols here (recursively)
  HashHelper.symbolize_keys_deep!(svc)


  name = "service-#{svc[:service_name]}"
  should_notify = should_notify_service?(name)

  supervisor_service name do
    command         "#{bin_dir_for node, 'service'}/scalrpy_proxy" \
                    " #{run_dir_for node, 'service'}/#{svc[:service_name]}.pid" \
                    " #{node[:scalr_server][:install_root]}/embedded/bin/python" \
                    " #{scalr_bundle_path node}/app/python/scalrpy/#{svc[:service_module]}.py" \
                    " --pid-file=#{run_dir_for node, 'service'}/#{svc[:service_name]}.pid" \
                    " --log-file=#{log_dir_for node, 'service'}/#{svc[:service_name]}.log" \
                    " --user=#{node[:scalr_server][:app][:user]}" \
                    " --group=#{node[:scalr_server][:app][:user]}" \
                    " --config=#{scalr_bundle_path node}/app/etc/config.yml" \
                    ' --verbosity=INFO' \
                    " #{svc[:service_extra_args]}" \
                    # Note: 'start' is added by the proxy.
    stdout_logfile  "#{log_dir_for node, 'supervisor'}/#{name}.log"
    stderr_logfile  "#{log_dir_for node, 'supervisor'}/#{name}.err"
    action          [:enable, :start]
    autostart       true
    subscribes      :restart, 'template[scalr_config]' if should_notify
    subscribes      :restart, 'file[scalr_cryptokey]' if should_notify
    subscribes      :restart, 'file[scalr_id]' if should_notify
  end
end
