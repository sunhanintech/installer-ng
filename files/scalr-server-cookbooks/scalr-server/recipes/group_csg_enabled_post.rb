supervisor_service 'cloud-service-gateway' do
  description     "Cloud Service Gateway"
  command         "#{node[:scalr_server][:install_root]}/embedded/bin/mitmdump" \
                  " -p #{node[:scalr_server][:csg][:cert]}" \
                  " --cadir=#{node[:scalr_server][:install_root]}/embedded/scalr/app/etc/csg" \
                  " -s #{node[:scalr_server][:install_root]}/embedded/scalr/app/python/fatmouse/csg/proxy.py" \
                  ' -DFOREGROUND'
  stdout_logfile  "#{node[:scalr_server][:install_root]}/var/log/service/csg.log"
  redirect_stderr true
  autostart       true
  startsecs       5
  action          [:enable, :start]
end
