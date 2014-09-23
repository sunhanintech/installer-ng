include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"
include_recipe "python::virtualenv"

# Install dependencies that ae required to build the various Python modules we will need to deploy in the virtualenv.
# Dependencies:
#   - libffi: ?
#   - libevent: gevent
#   - openssl: various crypto libs
#   - swig: m2crypto
#   - cairo, pango, glib, xml2, rrd: python-rrdtool
case node[:platform]
when 'redhat', 'centos', 'fedora'
  pkgs = %w{libffi-devel libevent-devel openssl-devel swig cairo-devel pango-devel glib2-devel libxml2-devel rrdtool-devel}
when 'ubuntu'  #TODO: Debian...
  pkgs = %w{libffi-dev libevent-dev libssl-dev swig libcairo2-dev libpango1.0-dev libglib2.0-dev libxml2-dev librrd-dev}
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

# Let the fun begin! M2Crypto isn't installable from pip on RHEL platforms, so we
# need to manually install it and run the fedora_setup.sh script provided by RHEL
case node[:platform_family]
when 'rhel'
  package 'wget'
  fedora_setup = 'https://raw.githubusercontent.com/M2Crypto/M2Crypto/master/fedora_setup.sh'
  bash 'install_m2crypto' do
    code <<-EOH
    set -o errexit
    set -o nounset
    work_dir=$(mktemp -d)
    cd -- "$work_dir"
    #{node[:scalr][:python][:venv_pip]} install --download "$work_dir" --no-deps m2crypto
    tar -xzvf *.tar.gz
    rm *.tar.gz
    cd M2Crypto*
    wget "#{fedora_setup}"
    fedora_setup=$(basename "#{fedora_setup}")
    chmod +x "$fedora_setup"
    PATH="#{node[:scalr][:python][:venv_bin]}:$PATH" "./$fedora_setup" install
    cd /
    rm -r $work_dir
    EOH
    not_if "#{node[:scalr][:python][:venv_pip]} freeze | grep -i m2crypto"
  end
end

# Install dependencies in the virtual environment
execute "Install Scalrpy" do
  command     "#{node[:scalr][:python][:venv_pip]} install --no-use-wheel --requirement requirements.txt"
  cwd         "#{node[:scalr][:core][:location]}/app/python"
end
