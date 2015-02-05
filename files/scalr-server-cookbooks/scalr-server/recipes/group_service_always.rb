disabled_services(node, :python).each do |svc|
  supervisor_service "service-#{svc[:name]}" do
    action service_is_up?(node, "service-#{svc[:name]}") ? [:stop, :disable] : [:disable]
  end
end

if enabled_services(node, :php).empty?
  supervisor_service 'zmq_service' do
    action service_exists?(node, 'zmq_service') ? [:stop, :disable] : [:disable]
  end
end
