supervisor_service 'mysql' do
  action service_exists?(node, 'mysql') ? [:stop, :disable] : [:disable]
end
