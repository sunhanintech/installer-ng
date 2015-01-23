[4, 6].each do |ip_version|

  # We open if the web server is listening on this host.
  iptables_ng_rule "scalr-web-#{ip_version}" do
    ip_version      ip_version
    rule            '--protocol tcp --dport 80 --match state --state NEW --jump ACCEPT'  # TODO - Make port configurable.
    action          node[:scalr_server][:web][:enable] ? :create : :delete
    ignore_failure  true # We're trying both ipv4 and ipv6 - Just ignore failures.
  end

  # We open if the plotter is listening on this host.
  iptables_ng_rule "scalr-plotter-#{ip_version}" do
    ip_version      ip_version
    rule            "--protocol tcp --dport #{node[:scalr_server][:service][:plotter_bind_port]} --match state --state NEW --jump ACCEPT"
    action          (enabled_services(node, :python).collect {|svc| svc[:service_name]}).include? 'plotter' ? :create : :delete
    ignore_failure  true
  end

  # We'll open the MySQL port if MySQL was configured to not listen on 127.0.0.1 or localhost. That's a heuristic,
  # of course, but the extras recipe is for quick and dirty setup, not fine-tuning.
  iptables_ng_rule "scalr-mysql-#{ip_version}" do
    ip_version      ip_version
    rule            "--protocol tcp --dport #{node[:scalr_server][:mysql][:bind_port]} --match state --state NEW --jump ACCEPT"
    action          (node[:scalr_server][:mysql][:enable] && !%w{localhost 127.0.0.1}.include?(node[:scalr_server][:mysql][:bind_host])) ? :create : :delete
    ignore_failure  true
  end
end
