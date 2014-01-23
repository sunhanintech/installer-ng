case node[:platform_family]
when 'rhel', 'fedora'
  pkgs = %w{net-snmp net-snmp-utils}
when 'debian'
  pkgs = %w{snmp snmp-mibs-downloader}
end

pkgs.each do |pkg|
  package pkg
end
