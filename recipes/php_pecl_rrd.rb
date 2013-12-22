case node[:platform_family]

when 'rhel'
  package 'rrdtool-devel'
when 'debian'
  package 'librrd-dev'
end


php_pear 'rrd' do
  action :install
  version '1.1.1'
end

scalr_core_phpmod 'rrd'
