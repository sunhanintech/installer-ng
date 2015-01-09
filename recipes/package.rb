cookbook = run_context.cookbook_collection[cookbook_name]
git_ssh_wrapper = cookbook.preferred_filename_on_disk_location(node, :files, 'chef_ssh_deploy_wrapper.sh')

# Deploy Scalr Core
package 'bash'
package 'coreutils'
package 'git'

# Passing environment to deploy_revision just... doesn't work.
ruby_block 'load ssh key' do
  block do
    ENV['GIT_SSH_KEY_BODY'] = node[:scalr][:deployment][:ssh_key]
  end
end

deploy_revision node[:scalr][:package][:name] do
  repo              node[:scalr][:package][:repo]
  deploy_to         node[:scalr][:package][:deploy_to]
  revision          node[:scalr][:package][:revision]
  ssh_wrapper       git_ssh_wrapper
  user              node[:scalr][:core][:users][:service]
  group             node[:scalr][:core][:group]
  rollback_on_error true
  symlink_before_migrate.clear
  create_dirs_before_symlink.clear
  purge_before_symlink.clear
  symlinks.clear
end

# This *has* to be in a ruby block, otherwise it'll be removed from the environment before this even runs!
ruby_block 'unload ssh key' do
  block do
    ENV.delete('GIT_SSH_KEY_BODY')
  end
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

# Create the cryptokey file and set permissions.
# This stays empty the validate step, which will generate the cryptokey
file node[:scalr][:core][:cryptokey_path] do
    owner node[:scalr][:core][:users][:service]
    group node[:scalr][:core][:group]
    mode  0640
end

# Create the ID file
# This one has a predefined value, because we use the ID in multiple locations
file node[:scalr][:core][:id_path] do
    owner   node[:scalr][:core][:users][:service]
    group   node[:scalr][:core][:group]
    mode    0640
    content node[:scalr_server][:app][:id]
end
