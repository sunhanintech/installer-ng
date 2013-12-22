require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def use_mod?
  node[:platform_family] == 'debian'
end

action :enable do
  Chef::Log.info "Enabling php5 mod: #{new_resource.mod}"
  if use_mod?
    shell_out! 'php5enmod', new_resource.mod
    new_resource.updated_by_last_action true
  end
end

action :disable do
  Chef::Log.info "Disabling php5 mod: #{new_resource.mod}"
  if use_mod?
    shell_out! 'php5dismod', new_resource.mod
    new_resource.updated_by_last_action true
  end
end
