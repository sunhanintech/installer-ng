supervisor_service 'rrd' do
  description "Stop rrd service"
  action service_is_up?(node, 'rrd') ? [:stop, :disable] : [:disable]
end
