supervisor_service 'cron' do
  action File.exist?("#{node['supervisor']['dir']}/cron.conf") ? [:stop, :disable] : [:disable]
end
