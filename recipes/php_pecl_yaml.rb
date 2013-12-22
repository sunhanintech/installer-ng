dep_pkgs = value_for_platform(
  %W{centos redhat } => %W{},
  %W{debian ubuntu}  => %W{libmagic-dev libyaml-dev}
)

dep_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

php_pear 'yaml' do
  action :install
  version '1.1.1'
end
