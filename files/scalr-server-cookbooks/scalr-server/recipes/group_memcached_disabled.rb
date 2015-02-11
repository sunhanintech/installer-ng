supervisor_service 'memcached' do
  action service_is_up?(node, 'memcached') ? [:stop, :disable] : [:disable]
end
