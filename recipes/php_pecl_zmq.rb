case node[:platform_family]

when 'rhel'
  package 'zeromq-devel'
when 'debian'
  package 'libzmq-dev'
end

php_pear 'zmq' do
  action :install
  version '1.1.2'
end

scalr_core_phpmod 'zmq'
