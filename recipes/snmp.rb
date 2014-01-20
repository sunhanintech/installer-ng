case node[:platform]
when 'redhat', 'centos', 'fedora'
  pkgs = %w{net-snmp net-snmp-utils}
when 'ubuntu'  #TODO: Debian...
  pkgs = %w{snmp snmp-mibs-downloader}
end

pkgs.each do |pkg|
  package pkg
end
