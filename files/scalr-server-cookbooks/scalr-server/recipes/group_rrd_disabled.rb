supervisor_service 'rrd' do
  action service_is_up?(node, 'rrd') ? [:stop, :disable] : [:disable]
end
