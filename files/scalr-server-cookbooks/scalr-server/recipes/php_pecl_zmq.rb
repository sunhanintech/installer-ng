case node[:platform_family]
when 'rhel'
  case node[:platform_version].to_i
  when 6
    package 'zeromq-devel'
  when 7
    package 'zeromq3-devel'
  end
when 'debian'
  package 'libzmq-dev'
end

php_pear 'zmq' do
  action :install
  version '1.1.2'
end

scalr_server_phpmod 'zmq'
