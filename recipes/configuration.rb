template node[:scalr][:core][:configuration] do
  source "#{node[:scalr][:package][:release]}-config.yml.erb"
  mode 0640
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end

ruby_block "Set Endpoint Hostname" do
  block do
    if not node[:scalr][:is_enterprise] and node[:scalr][:endpoint][:set_hostname]
      line = "#{node[:scalr][:endpoint][:local_ip]} #{node[:scalr][:endpoint][:local_ip]}"

      file = Chef::Util::FileEdit.new("/etc/hosts")
      file.insert_line_if_no_match(Regexp.escape(line), line)
      file.write_file
    end
  end
end
