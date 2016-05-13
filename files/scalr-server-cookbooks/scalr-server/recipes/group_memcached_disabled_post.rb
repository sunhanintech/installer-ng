supervisor_service 'memcached' do
  description "Stop memcached service"
  action service_is_up?(node, 'memcached') ? [:stop, :disable] : [:disable]
end
