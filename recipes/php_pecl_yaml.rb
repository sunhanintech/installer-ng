case node[:platform_family]

when 'rhel'
  package 'libyaml-devel'
when 'debian'
  package 'libyaml-dev'
end

php_pear 'yaml' do
  action :install
  version '1.1.1'
end

php_enable_mod 'yaml'
