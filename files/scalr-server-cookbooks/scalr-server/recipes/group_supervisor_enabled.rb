#
# Cookbook Name:: supervisor
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
# Copyright 2011, Scalr, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Supervisor configuration
directory "#{etc_dir_for node, 'supervisor'}/conf.d" do
  owner node[:scalr_server][:supervisor][:user]
  mode  0755
  recursive true
end

template "#{etc_dir_for node, 'supervisor'}/supervisord.conf" do
  source 'supervisor/supervisord.conf.erb'
  owner node[:scalr_server][:supervisor][:user]
  mode  0644
  helpers(Scalr::PathHelper)
end

directory run_dir_for(node, 'supervisor') do
  owner node[:scalr_server][:supervisor][:user]
  mode 0755
  recursive true
end

directory log_dir_for(node, 'supervisor') do
  owner node[:scalr_server][:supervisor][:user]
  mode 0755
  recursive true
end

# TODO - Init template for it to always start!

# This is for supervisorctl to easily find our supervisor instance.
link '/etc/supervisord.conf' do
  to "#{etc_dir_for node, 'supervisor'}/supervisord.conf"
end



template '/etc/default/supervisor' do
  source    'debian/supervisor.default.erb'
  cookbook  'supervisor'
  owner     'root'
  group     'root'
  mode      0644
  only_if   { platform_family?('debian') }
end

init_template_dir = value_for_platform_family(
    %w(rhel fedora) => 'rhel',
    'debian' => 'debian'
)

case node['platform']
  when 'amazon', 'centos', 'debian', 'fedora', 'redhat', 'ubuntu'
    template '/etc/init.d/supervisor' do
      source    "supervisor/#{init_template_dir}/supervisor.init.erb"
      owner     'root'
      group     'root'
      mode      '755'
      variables({
                    :supervisord => "#{node[:scalr_server][:install_root]}/embedded/bin/supervisord",
                    :log_dir => log_dir_for(node, 'supervisor'),
                    :run_dir => run_dir_for(node, 'supervisor')
                })
    end

    service 'supervisor' do
      supports :status => true, :restart => true
      action [:enable, :start]
    end
  else
    # TODO - Throw error
end
