require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def use_mod?
  node[:platform_family] == 'debian'
end

action :enable do
  Chef::Log.info "Enabling php5 mod: #{new_resource.mod}"
  if use_mod?
    p = shell_out 'php5enmod', new_resource.mod
    p.invalid! if p.stderr.include? "Module #{new_resource.mod} ini file doesn't exist"
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
