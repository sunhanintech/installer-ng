case node[:platform_family]

when 'rhel'
  package 'file-devel'
  package 'zlib-devel'
  package 'curl-devel'
when 'debian'
  package 'zlib1g-dev'
  package 'libmagic-dev'
  package 'libcurl4-openssl-dev'
end


php_pear 'pecl_http' do
  action :install
  version '1.7.6'
end

php_enable_mod 'http'
