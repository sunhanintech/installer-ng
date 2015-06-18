supervisor_service 'nginx' do
  action service_is_up?(node, 'nginx') ? [:stop, :disable] : [:disable]
end
