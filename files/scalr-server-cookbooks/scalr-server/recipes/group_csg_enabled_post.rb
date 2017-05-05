supervisor_service 'cloud-service-gateway' do
  description     "Cloud Service Gateway"
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/mitmdump" \
                  " -p #{node[:scalr_server][:csg][:bind_port]}" \
                  " --app-host #{node[:scalr_server][:csg][:bind_host]}" \
                  " --cadir=#{node[:scalr_server][:install_root]}/etc/scalr/csg" \
                  " -s #{node[:scalr_server][:install_root]}/embedded/scalr/app/python/fatmouse/csg/proxy.py"
  stdout_logfile  "#{node[:scalr_server][:install_root]}/var/log/service/cloud-service-gateway.log"
  environment     'PYTHONPATH' => "#{node[:scalr_server][:install_root]}/embedded/scalr/app/python/fatmouse"
  redirect_stderr true
  autostart       true
  startsecs       5
  action          [:enable, :start]
end
