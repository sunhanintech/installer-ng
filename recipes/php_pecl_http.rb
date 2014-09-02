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

php_pear 'pecl_http' do  # Can't I just override the provider here?
  action :install
  version '1.7.6'
end

# Php Pear does not recognize this as a PECL.
# Only on ... debian.
if node[:platform_family] == 'debian'
  cookbook_file "#{node['php']['ext_conf_dir']}/http.ini" do
    owner 'root'
    group 'root'
    mode 0644
    source "http.ini"
  end
end

scalr_core_phpmod 'http'
