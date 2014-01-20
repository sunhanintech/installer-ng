include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"

case node[:platform]
when 'redhat', 'centos', 'fedora'
  pkgs = %w{python-setuptools m2crypto libevent-devel net-snmp-python rrdtool-python}
when 'ubuntu'  #TODO: Debian...
  pkgs = %w{python-setuptools m2crypto libevent-dev libsnmp-python python-rrdtool}
end

pkgs.each do |pkg|
  package pkg
end

execute "Install Scalrpy" do
  command "python setup.py install"
  cwd "#{node[:scalr][:core][:location]}/app/python"
  not_if "python -m scalrpy"
end
