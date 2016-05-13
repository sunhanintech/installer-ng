enabled_services(node, :python).each do |svc|
  name = "service-#{svc[:name]}"
  should_restart = service_is_up?(node, name)

  supervisor_service name do
    description     "(Re)Start " + name + " service"
    command         "#{bin_dir_for node, 'service'}/scalrpy_proxy" \
                    " #{run_dir_for node, 'service'}/#{svc[:name]}.pid" \
                    " #{node[:scalr_server][:install_root]}/embedded/bin/python" \
                    " #{scalr_bundle_path node}/app/python/scalrpy/#{svc[:service_module]}.py" \
                    " --pid-file=#{run_dir_for node, 'service'}/#{svc[:name]}.pid" \
                    " --log-file=#{log_dir_for node, 'service'}/python-#{svc[:name]}.log" \
                    " --user=#{node[:scalr_server][:app][:user]}" \
                    " --group=#{node[:scalr_server][:app][:user]}" \
                    " --config=#{scalr_bundle_path node}/app/etc/config.yml" \
                    ' --verbosity=INFO' \
                    " #{svc[:service_extra_args]}" \
                    # Note: 'start' is added by the proxy.
    stdout_logfile  "#{log_dir_for node, 'supervisor'}/#{name}.log"
    stderr_logfile  "#{log_dir_for node, 'supervisor'}/#{name}.err"
    autostart       true
    action          [:enable, :start]
    subscribes      :restart, 'file[scalr_config]' if should_restart
    subscribes      :restart, 'file[scalr_code]' if should_restart
    subscribes      :restart, 'file[scalr_cryptokey]' if should_restart
    subscribes      :restart, 'file[scalr_id]' if should_restart
    subscribes      :restart, 'user[scalr_user]' if should_restart
  end
end

disabled_services(node, :python).each do |svc|
  name = "service-#{svc[:name]}"

  supervisor_service name do
    description "Stop " + name + " service"
    action service_is_up?(node, "service-#{svc[:name]}") ? [:stop, :disable] : [:disable]
  end
end

zmq_name = 'zmq_service'

if enabled_services(node, :php).any?
  should_restart = service_is_up?(node, zmq_name)

  supervisor_service zmq_name do
    description     "(Re)Start PHP service"
    command         "#{node[:scalr_server][:install_root]}/embedded/bin/php -c #{etc_dir_for node, 'php'}" \
                    " #{scalr_bundle_path node}/app/cron/service.php"
    stdout_logfile  "#{log_dir_for node, 'supervisor'}/zmq_service.log"
    stderr_logfile  "#{log_dir_for node, 'supervisor'}/zmq_service.err"
    autostart       true
    user            node[:scalr_server][:app][:user]
    action          [:enable, :start]
    subscribes      :restart, 'file[scalr_config]' if should_restart
    subscribes      :restart, 'file[scalr_code]' if should_restart
    subscribes      :restart, 'file[scalr_cryptokey]' if should_restart
    subscribes      :restart, 'file[scalr_id]' if should_restart
    subscribes      :restart, 'template[php_ini]' if should_restart
    subscribes      :restart, 'template[ldap_conf]' if should_restart
  end
else
  supervisor_service zmq_name do
    description "Stop zmq service"
    action service_exists?(node, 'zmq_service') ? [:stop, :disable] : [:disable]
  end
end
