# System
include_recipe 'scalr-core::repos'
include_recipe 'apt'

# Time
include_recipe 'timezone-ii'
include_recipe 'ntp'

# Users
include_recipe 'scalr-core::users'

# Services
# Note: must be defined first, otherwise Chef will complain that the init
# files are missing. We're not launching them yet, though.
include_recipe 'scalr-core::services'

# Scalr Code
include_recipe 'scalr-core::package'

# Set selinux policy
include_recipe 'scalr-core::selinux'

# Runtime dependencies
include_recipe 'scalr-core::php'
include_recipe 'scalr-core::snmp'
include_recipe 'scalr-core::scalrpy'
include_recipe 'scalr-core::rrdcached'

# Database Configuration
include_recipe 'scalr-core::database'

# Set sysctl requirements
include_recipe 'scalr-core::sysctl'

# Firewall configuration
include_recipe 'scalr-core::firewall'

# Service Launch
include_recipe 'scalr-core::web'
include_recipe 'scalr-core::cron'

# Scalr-specific PHP ini settngs
include_recipe 'scalr-core::configuration'
include_recipe "scalr-core::php_settings"

# Validate
include_recipe 'scalr-core::validate'

# Set admin login
include_recipe 'scalr-core::admin'
