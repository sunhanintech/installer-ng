case node[:platform_family]

when 'rhel'
  package 'libssh2-devel'
when 'debian'
  package 'libssh2-1-dev'
end


php_pear 'ssh2' do
  action :install
  version '0.12'
end

scalr_core_phpmod 'ssh2'
