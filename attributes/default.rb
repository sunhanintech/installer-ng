# Compile PHP from source, because packages.
include_attribute "php"

default['php']['install_method'] = 'source'
default['php']['configure_options'] = default['php']['configure_options'].concat(%W{--enable-pcntl --with-snmp --with-ldap})

case node["platform_family"]
  when "rhel", "centos"
    default[:phpdeps][:ldap] = %W{openldap}
    default[:phpdeps][:snmp] = %W{net-snmp-devel}
  when "debian", "ubuntu"
    default[:phpdeps][:ldap]= %W{libldap2-dev}
    default[:phpdeps][:snmp] = %W{libsnmp-dev}
end
