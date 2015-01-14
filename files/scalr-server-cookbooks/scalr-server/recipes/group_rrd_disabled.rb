supervisor_service 'rrd' do
  action service_exists?('rrd') ? [:stop, :disable] : [:disable]
end
