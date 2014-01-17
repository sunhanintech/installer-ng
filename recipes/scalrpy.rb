#TODO: Package names on RHEL!
pkgs = %W{python-setuptools python-dev m2crypto snmp libsnmp-python python-rrdtool python-pip}

pkgs.each do |pkg|
  package pkg
end

include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"

python_pip 'setuptools' do  # If setuptools is < 0.8, then a wheel install will fail!
  action :upgrade
  options '--no-use-wheel'
end

execute "Install Scalrpy" do
  command "python setup.py install"
  cwd "#{node[:scalr][:core][:location]}/app/python"
  not_if "python -m scalrpy"
end
