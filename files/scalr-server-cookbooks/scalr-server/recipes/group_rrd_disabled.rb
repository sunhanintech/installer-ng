supervisor_service 'rrd' do
  action service_exists?(node, 'rrd') ? [:stop, :disable] : [:disable]
end
