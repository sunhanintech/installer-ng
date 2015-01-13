supervisor_service 'mysql' do
  action File.exist?("#{node['supervisor']['dir']}/mysql.conf") ? [:stop, :disable] : [:disable]
end
