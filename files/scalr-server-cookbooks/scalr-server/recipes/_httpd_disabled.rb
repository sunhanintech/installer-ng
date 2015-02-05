supervisor_service 'httpd' do
  action service_is_up?(node, 'httpd') ? [:stop, :disable] : [:disable]
end
