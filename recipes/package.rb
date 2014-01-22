# Deploy Scalr Core

artifact_deploy node[:scalr][:core][:package][:name] do
  artifact_location node[:scalr][:core][:package][:url]
  artifact_checksum node[:scalr][:core][:package][:checksum]
  version node[:scalr][:core][:package][:version]
  deploy_to node[:scalr][:core][:package][:deploy_to]
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
end


[
  "#{node[:scalr][:core][:location]}/cache",
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

crypto_key_file = "#{node[:scalr][:core][:location]}/app/etc/.cryptokey"
id_file = "#{node[:scalr][:core][:location]}/app/etc/id"

[crypto_key_file, id_file].each do |f|
  file f do
    owner node[:scalr][:core][:users][:service]
    group node[:scalr][:core][:group]
    mode 0640
  end
end
