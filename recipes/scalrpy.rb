include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"
include_recipe "python::virtualenv"

# Install dependencies that ae required to build the various Python modules we will need to deploy in the virtualenv.
case node[:platform]
when 'redhat', 'centos', 'fedora'
  pkgs = %w{libffi-devel libevent-devel openssl-devel python-setuptools}
when 'ubuntu'  #TODO: Debian...
  pkgs = %w{libffi-dev libevent-dev libssl-dev python-setuptools}
end

pkgs.each do |pkg|
  package pkg
end

# Create virtualenv
python_virtualenv node[:scalr][:python][:venv] do
  owner  node[:scalr][:core][:users][:service]
  group  node[:scalr][:core][:group]
  action :create
end

# Install dependencies in the virtual environment
execute "Install Scalrpy" do
  command     "#{node[:scalr][:python][:venv_pip]} install --no-use-wheel --requirement requirements.txt"
  cwd         "#{node[:scalr][:core][:location]}/app/python"
end
