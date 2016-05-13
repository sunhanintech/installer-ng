supervisor_service 'httpd' do
  description "Stop httpd service"
  action service_is_up?(node, 'httpd') ? [:stop, :disable] : [:disable]
end
