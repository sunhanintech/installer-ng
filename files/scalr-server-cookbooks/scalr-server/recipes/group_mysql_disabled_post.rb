supervisor_service 'mysql' do
  description "Stop MySQL service"
  action service_is_up?(node, 'mysql') ? [:stop, :disable] : [:disable]
end
