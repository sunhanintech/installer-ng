directory "#{node[:scalr_server][:install_root]}/etc/scalr/csg" do
  description "Create directory (#{node[:scalr_server][:install_root]}/etc/scalr/csg)"
  owner     'root'
  group     'root'
  mode      0755
end

mitmproxy_cert = "#{node[:scalr_server][:install_root]}/etc/scalr/csg/mitmproxy-ca-cert.pem"
file mitmproxy_cert do 
  description "Generating mitmproxy certificate (#{mitmproxy_cert})"
  content IO.read(node[:scalr_server][:csg][:cert])
  owner 'root'
  group 'root'
  mode 0755
  action :create
  notifies  :restart, 'supervisor_service[cloud-service-gateway]' if service_is_up?(node, 'csg')
end

mitmproxy_key = "#{node[:scalr_server][:install_root]}/etc/scalr/csg/mitmproxy-ca.pem"
file mitmproxy_key do
  description "Generating mitmproxy key (#{mitmproxy_key})"
  content IO.read(node[:scalr_server][:csg][:cert]) + IO.read(node[:scalr_server][:csg][:key])
  owner 'root'
  group 'root'
  mode 0755
  action :create
  notifies  :restart, 'supervisor_service[cloud-service-gateway]' if service_is_up?(node, 'csg')
end
