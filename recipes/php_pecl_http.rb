case node[:platform]

when 'redhat', 'centos'
  package 'file-devel'
  package 'zlib-devel'
  #package 'curl-devel'  # Installed in php::default
when 'ubuntu', 'debian'
  package 'zlib1g-dev'
  package 'libmagic-dev'
  #package 'libcurl4-openssl-dev'  # Installed in php::default
end

php_pear 'pecl_http' do
  action :install
  version '1.7.6'
end
