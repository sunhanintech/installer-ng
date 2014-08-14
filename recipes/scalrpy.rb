include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"
include_recipe "python::virtualenv"

# Required packages include:
# To build Python extensions: libffi, libevent, libopenssl
# Actual Python packages that aren't practical / possible to install using pip: m2crypto, snmp, rrdtool
# Python setuptools, to actually install

case node[:platform]
when 'redhat', 'centos', 'fedora'
  pkgs = %w{libffi-devel libevent-devel openssl-devel python-setuptools m2crypto net-snmp-python rrdtool-python}
when 'ubuntu'  #TODO: Debian...
  pkgs = %w{libffi-dev libevent-dev libssl-dev python-setuptools python-m2crypto libsnmp-python python-rrdtool}
end

pkgs.each do |pkg|
  package pkg
end

# Create virtualenv

python_virtualenv node[:scalr][:python][:venv] do
  owner  node[:scalr][:core][:users][:service]
  group  node[:scalr][:core][:group]
  options "--system-site-packages"  # We need this for the few packages mentioned above
  action :create
end

# Prioritize our virtualenv python and pip in the installer
execute "Install Scalrpy" do
  command     "#{node[:scalr][:python][:venv_python]} setup.py install"
  cwd         "#{node[:scalr][:core][:location]}/app/python"
  environment('PATH' => node[:scalr][:python][:venv_path])
end
