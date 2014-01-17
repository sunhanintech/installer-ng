# Deploy Scalr Core

artifact_deploy node[:scalr][:core][:package][:name] do
  artifact_location node[:scalr][:core][:package][:url]
  artifact_checksum node[:scalr][:core][:package][:checksum]
  version node[:scalr][:core][:package][:version]
  deploy_to node[:scalr][:core][:package][:deploy_to]
  owner 'root'
  group 'root'
end

directory "#{node[:scalr][:core][:location]}/cache" do
  owner node[:scalr][:core][:users][:service]
  group node[:scalr][:core][:group]
  action :create
end
