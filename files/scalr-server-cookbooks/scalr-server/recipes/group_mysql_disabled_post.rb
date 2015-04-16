supervisor_service 'mysql' do
  action service_is_up?(node, 'mysql') ? [:stop, :disable] : [:disable]
end
