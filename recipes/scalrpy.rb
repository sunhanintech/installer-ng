include_recipe "python::#{node['python']['install_method']}"
include_recipe 'python::pip'

# NOTE: the python cookbook has a pending issue to resolve the following hack
# All the include_recipe blocks and this can be replaced with include_recipe "python"
# once they fix it.
# https://github.com/poise/python/issues/100
python_pip 'setuptools' do
  action :upgrade
  version node['python']['setuptools_version']
end

include_recipe 'python::virtualenv'

if has_scalrpy2? node
  # In Scalrpy v2, we build everything in the virtualenv
  pkgs = value_for_platform_family(
      %w(rhel fedora) => %w(libffi-devel libevent-devel openssl-devel swig cairo-devel pango-devel glib2-devel libxml2-devel rrdtool-devel),
      'debian' => %w(libffi-dev libevent-dev libssl-dev swig libcairo2-dev libpango1.0-dev libglib2.0-dev libxml2-dev librrd-dev)
  )
else
  # In Scalrpy v1, some packages have to be installed outside the virtualenv
  pkgs = value_for_platform_family(
      %w(rhel fedora) => %w(libffi-devel libevent-devel openssl-devel python-setuptools m2crypto net-snmp-python rrdtool-python),
      'debian' => %w(libffi-dev libevent-dev libssl-dev python-setuptools python-m2crypto libsnmp-python python-rrdtool)
  )
end

pkgs.each do |pkg|
  package pkg
end

# Create virtualenv

python_virtualenv node[:scalr][:python][:venv] do
  owner  node[:scalr][:core][:users][:service]
  group  node[:scalr][:core][:group]
  options (has_scalrpy2? node) ? '' : '--system-site-packages'
  action :create
end

# Ensure pip is the most up-to-date (and has the --no-use-wheel option)

python_pip "pip" do
  user        node[:scalr][:core][:users][:service]
  group       node[:scalr][:core][:group]
  virtualenv  node[:scalr][:python][:venv]
  action      :upgrade
end

# Now, install "tricky" dependencies.
# On Scalr 5.1, this means installing M2Crypto on RHEL.
# On Scalr 5.0, this means installing a few packages we want to pin to a moe up-to-date version than what
# may already be on the system

if has_scalrpy2? node

  # Let the fun begin! M2Crypto isn't installable from pip on RHEL platforms, so we
  # need to manually install it and run the fedora_setup.sh script provided for RHEL
  if node[:platform_family] == 'rhel'

    package 'wget' do
      # Old wget packages may not have support for alternative names in SSL certificates,
      # which GitHub uses (and we use GitHub in the install script below).
      action :upgrade
    end

    template "#{Chef::Config[:file_cache_path]}/rhel-install-m2crypto.sh" do
      source    'rhel-install-m2crypto.sh.erb'
      variables :fedora_setup => 'https://raw.githubusercontent.com/M2Crypto/M2Crypto/master/fedora_setup.sh'
      mode      0700
      helpers(Scalr::PathHelper)
    end

    execute "#{Chef::Config[:file_cache_path]}/rhel-install-m2crypto.sh" do
      not_if "#{venv_pip node} freeze | grep -i m2crypto"
      environment('PATH' => (venv_build_path node))
    end
  end

else

  # Force install dependencies where conflicts may arise
  node[:scalr][:python][:venv_force_install].each do |pkg, version|
    python_pip pkg do
      user        node[:scalr][:core][:users][:service]
      group       node[:scalr][:core][:group]
      virtualenv  node[:scalr][:python][:venv]
      action      :upgrade
      version     version
      options     '--ignore-installed --no-use-wheel'
    end
  end
end


# Prioritize our virtualenv python and pip in the installer

if has_scalrpy2? node
  install_cmd = "#{venv_pip node} install --no-use-wheel --requirement requirements.txt"
else
  install_cmd = "#{venv_python node} setup.py install"
end

execute 'Install Scalrpy' do
  command     install_cmd
  cwd         "#{node[:scalr][:core][:location]}/app/python"
  environment('PATH' => (venv_build_path node))
end
