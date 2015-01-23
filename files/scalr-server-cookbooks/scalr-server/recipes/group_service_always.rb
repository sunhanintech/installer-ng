disabled_services(node).each do |svc|

  supervisor_service "service-#{svc[:service_name]}" do
    action service_exists?(node, "service-#{svc[:service_name]}") ? [:stop, :disable] : [:disable]
  end
end
