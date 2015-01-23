disabled_services(node, :python).each do |svc|
  supervisor_service "service-#{svc[:service_name]}" do
    action service_exists?(node, "service-#{svc[:service_name]}") ? [:stop, :disable] : [:disable]
  end
end

if enabled_services(node, :php).empty?
  supervisor_service 'zmq_service' do
    action service_exists?(node, 'zmq_service') ? [:stop, :disable] : [:disable]
  end
end
