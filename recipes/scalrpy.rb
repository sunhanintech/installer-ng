include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"

case node[:platform]
when 'redhat', 'centos', 'fedora'
  pkgs = %w{libffi-devel libevent-devel m2crypto python-setuptools net-snmp-python rrdtool-python}
when 'ubuntu'  #TODO: Debian...
  pkgs = %w{libffi-dev libevent-dev python-m2crypto python-setuptools libsnmp-python python-rrdtool}
end

pkgs.each do |pkg|
  package pkg
end

execute "Install Scalrpy" do
  command "python setup.py install"
  cwd "#{node[:scalr][:core][:location]}/app/python"
  not_if "python -m scalrpy"
end
