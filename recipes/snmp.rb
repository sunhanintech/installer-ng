case node[:platform]
when 'redhat', 'centos'
  pkgs = %W{net-snmp net-snmp-utils}
when 'ubuntu'  #TODO: Debian...
  pkgs = %W{snmp snmp-mibs-downloader}
end

pkgs.each do |pkg|
  package pkg
end
