dep_pkgs = value_for_platform(
  %W{centos redhat } => %W{},
  %W{debian ubuntu}  => %W{libmagic-dev libssh2-1-dev}
)

dep_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

php_pear 'ssh2' do
  action :install
  version '0.12'
end
