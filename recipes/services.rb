python = "/usr/bin/python"

daemons = [
  {:daemon_name => 'msgsender', :daemon_module => 'msg_sender', :daemon_desc => 'Scalr Messaging Daemon', :daemon_extra_args => '' },
  {:daemon_name => 'dbqueue', :daemon_module => 'dbqueue_event', :daemon_desc => 'Scalr DB Queue Event Poller', :daemon_extra_args => '' },
  {:daemon_name => 'plotter', :daemon_module => 'load_statistics', :daemon_desc => 'Scalr Load Stats Poller', :daemon_extra_args => '--poller' },
  {:daemon_name => 'poller', :daemon_module => 'load_statistics', :daemon_desc => 'Scalr Load Stats Plotter', :daemon_extra_args => '--plotter' },
]

daemons.each do |daemon|
  args = daemon.clone
  args["python"] = "/usr/bin/python" # TODO: Dynamic?

  template "/etc/init/#{args[:daemon_name]}.conf" do
    source "upstart-service.conf.erb"
    mode 0644
    owner "root"
    group "root"
    variables args
  end

  service daemon[:daemon_name] do
    provider Chef::Provider::Service::Upstart
    subscribes :restart, "template[#{node[:scalr][:core][:configuration]}]", :delayed
    action :nothing
  end
end
