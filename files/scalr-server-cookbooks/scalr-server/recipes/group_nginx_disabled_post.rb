supervisor_service 'nginx' do
  description "Stop nginx service"
  action service_is_up?(node, 'nginx') ? [:stop, :disable] : [:disable]
end
