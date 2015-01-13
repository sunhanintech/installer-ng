# !! Going to be much more complex than this.
enabled_services(node).each do |svc|
  HashHelper.symbolize_keys_deep!(svc)

  supervisor_service "worker-#{svc[:service_name]}" do
    action File.exist?("#{node['supervisor']['dir']}/worker-#{svc[:service_name]}.conf") ? [:stop, :disable] : [:disable]
  end
end
