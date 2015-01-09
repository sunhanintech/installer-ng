case node[:platform]

when 'redhat', 'centos', 'fedora'
  package 'net-snmp-devel'

when 'ubuntu', 'debian'
  package 'libsnmp-dev'

end
