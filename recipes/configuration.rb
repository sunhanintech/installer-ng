template node[:scalr][:core][:configuration] do
  source "config.yml.erb"
  mode 0640
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end

template node[:scalr][:core][:log_configuration] do
  source "log4php.xml.erb"
  mode 0644
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end

ruby_block "Set Endpoint Hostname" do
  block do
    if node[:scalr][:endpoint][:set_hostname]
      line = "#{node[:scalr][:endpoint][:local_ip]} #{node[:scalr][:endpoint][:local_ip]}"

      file = Chef::Util::FileEdit.new("/etc/hosts")
      file.insert_line_if_no_match(Regexp.escape(line), line)
      file.write_file
    end
  end
end
