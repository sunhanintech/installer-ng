package value_for_platform_family(['rhel', 'fedora'] => 'rrdtool-devel', 'debian' => 'librrd-dev')

php_pear 'rrd' do
  action :install
  version '1.1.3'
end

scalr_core_phpmod 'rrd'
