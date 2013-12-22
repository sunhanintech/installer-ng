case node[:platform]

when 'redhat', 'centos'
  package 'net-snmp-devel'

when 'ubuntu', 'debian'
  package 'libsnmp-dev'

end
