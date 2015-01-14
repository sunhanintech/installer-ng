supervisor_service 'httpd' do
  action File.exist?("#{node['supervisor']['dir']}/httpd.conf") ? [:stop, :disable] : [:disable]
end
