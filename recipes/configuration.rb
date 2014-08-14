template node[:scalr][:core][:configuration] do
  source "#{node[:scalr][:package][:version_obj].segments.first}-config.yml.erb"
  mode 0640
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end

ruby_block "Set Endpoint Hostname" do
  block do
    if not Gem::Dependency.new(nil, '~> 5.0').match?(nil, node.scalr.package.version) and node[:scalr][:endpoint][:set_hostname]
      line = "#{node[:scalr][:endpoint][:local_ip]} #{node[:scalr][:endpoint][:local_ip]}"
      file = Chef::Util::FileEdit.new("/etc/hosts")
      file.insert_line_if_no_match(Regexp.escape(line), line)
      file.write_file
    end
  end
end
