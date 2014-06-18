include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"
include_recipe "python::virtualenv"

case node[:platform]
when 'redhat', 'centos', 'fedora'
  pkgs = %w{libffi-devel libevent-devel m2crypto python-setuptools net-snmp-python rrdtool-python}
when 'ubuntu'  #TODO: Debian...
  pkgs = %w{libffi-dev libevent-dev python-m2crypto python-setuptools libsnmp-python python-rrdtool}
end

pkgs.each do |pkg|
  package pkg
end

# Create virtualenv and install dependencies

python_virtualenv node[:scalr][:python][:venv] do
  owner  node[:scalr][:core][:users][:service]
  group  node[:scalr][:core][:group]
  action :create
end

execute "Install Scalrpy" do
  command     "#{node[:scalr][:python][:venv_python]} setup.py install"
  cwd         "#{node[:scalr][:core][:location]}/app/python"
  not_if      "#{node[:scalr][:python][:venv_python]} -m scalrpy"
  path        path
  environment('PATH' => node[:scalr][:python][:venv_path])
end
