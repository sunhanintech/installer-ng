supervisor_service 'mysql' do
  action service_exists?('mysql') ? [:stop, :disable] : [:disable]
end
