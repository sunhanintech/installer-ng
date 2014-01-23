## Dependencies for extensions we're installing
#include_recipe "scalr-core::php_deps_ldap"
#include_recipe "scalr-core::php_deps_snmp"

# PHP itself, and its extensions
include_recipe "php"

# PECLs required by Scalr
include_recipe "scalr-core::php_pecl_http"
include_recipe "scalr-core::php_pecl_ssh2"
include_recipe "scalr-core::php_pecl_yaml"
include_recipe "scalr-core::php_pecl_rrd"
