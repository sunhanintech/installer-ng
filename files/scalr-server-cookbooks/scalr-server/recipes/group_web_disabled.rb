supervisor_service 'httpd' do
  action service_exists?('httpd') ? [:stop, :disable] : [:disable]
end
