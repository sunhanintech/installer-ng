disabled_services(node).each do |svc|
  HashHelper.symbolize_keys_deep!(svc)

  supervisor_service "service-#{svc[:service_name]}" do
    action service_exists?("service-#{svc[:service_name]}") ? [:stop, :disable] : [:disable]
  end
end
