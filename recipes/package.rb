# Prepare our SSH wrapper
# It will only be used if we deploy from SSH
package "git"

if  node[:scalr][:deployment][:ssh_key_path].length > 0 and node[:scalr][:deployment][:ssh_key].length > 0
  template node[:scalr][:deployment][:ssh_wrapper_path] do
    source    "chef_ssh_deploy_wrapper.erb"
    owner     Process.uid
    group     Process.gid
    mode      0770
  end

  file node[:scalr][:deployment][:ssh_key_path] do
    content   node[:scalr][:deployment][:ssh_key]
    owner     Process.uid
    group     Process.gid
    mode      0600
  end

  ssh_wrapper = node[:scalr][:deployment][:ssh_wrapper_path]
else
  ssh_wrapper = ""  # Don't use an SSH wrapper if there is nothing to wrap!
end

# Deploy Scalr Core
deploy_revision node[:scalr][:package][:name] do
  repo                        node[:scalr][:package][:repo]
  deploy_to                   node[:scalr][:package][:deploy_to]
  revision                    node[:scalr][:package][:revision]
  ssh_wrapper                 ssh_wrapper
  user                        node[:scalr][:core][:users][:service]
  group                       node[:scalr][:core][:group]
  rollback_on_error           true
  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear
  symlinks.clear
end

[
  "#{node[:scalr][:core][:location]}/app/cache",
  node[:scalr][:core][:log_dir],
  node[:scalr][:core][:pid_dir]
].each do |dir|
  directory dir do
    owner node[:scalr][:core][:users][:service]
    group node[:scalr][:core][:group]
    mode 0770
    action :create
  end
end


# Ensure those files are created and not world-readable
# before we add the data in them!

[
  node[:scalr][:core][:cryptokey_path],
  "#{node[:scalr][:core][:location]}/app/etc/id"
].each do |f|
  file f do
    owner node[:scalr][:core][:users][:service]
    group node[:scalr][:core][:group]
    mode 0640
  end
end
