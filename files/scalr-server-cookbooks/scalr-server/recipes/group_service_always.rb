disabled_services(node).each do |svc|
  HashHelper.symbolize_keys_deep!(svc)

  supervisor_service "service-#{svc[:service_name]}" do
    action File.exist?("#{node['supervisor']['dir']}/service-#{svc[:service_name]}.conf") ? [:stop, :disable] : [:disable]
  end
end
