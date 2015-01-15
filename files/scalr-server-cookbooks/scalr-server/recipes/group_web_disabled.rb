supervisor_service 'httpd' do
  action service_exists?(node, 'httpd') ? [:stop, :disable] : [:disable]
end
