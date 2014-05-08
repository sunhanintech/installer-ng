if node[:platform_family] == 'fedora'
  package 'redhat-lsb'  #TODO: Is that installed on Red Hat already?
end

node[:scalr][:daemons].each do |daemon|
  # We want to be able to mutate that array to add things to it
  args = daemon.deep_to_hash

  # deep_to_hash gives us strings, but we want symbols.
  args.keys.each do |key|
    args[(key.to_sym rescue key) || key] = args.delete(key)
  end

  args[:executable] = "/usr/bin/python" # TODO: Dynamic?
  args[:piddir] = node[:scalr][:core][:pid_dir]
  args[:pidfile] = "#{args[:piddir]}/#{args[:daemon_name]}.pid"
  args[:logfile] = "#{node[:scalr][:core][:log_dir]}/#{args[:daemon_name]}.log"
  args[:user] = node[:scalr][:core][:users][:service]
  args[:group] = node[:scalr][:core][:group]

  init_file = "/etc/init.d/#{args[:daemon_name]}"

  template init_file do
    source "#{node[:platform_family]}-init-service.erb"
    mode 0755
    owner "root"
    group "root"
    variables args
  end

  service daemon[:daemon_name] do
    supports   :restart => true
    subscribes :restart, "template[#{init_file}]", :delayed
    subscribes :restart, "template[#{node[:scalr][:core][:configuration]}]", :delayed
    subscribes :restart, "execute[Mark Install]", :delayed
    subscribes :restart, "ruby_block[Set Endpoint Hostname]", :delayed
    subscribes :restart, "deploy_revision[#{node[:scalr][:package][:name]}]", :delayed
    action     :enable
  end
end
