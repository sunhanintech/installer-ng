include_recipe 'apt'
include_recipe 'scalr-core::users'
include_recipe 'scalr-core::package'
include_recipe 'scalr-core::repos'
include_recipe 'scalr-core::php'
include_recipe 'scalr-core::snmp'

include_recipe 'scalr-core::database'
