# System
include_recipe 'scalr-server::repos'

# Cron
include_recipe 'cron'

# Users
include_recipe 'scalr-server::users'

# Services
# Note: must be defined first, otherwise Chef will complain that the init
# files are missing. We're not launching them yet, though.
include_recipe 'scalr-server::stub-services'

# Scalr Code
include_recipe 'scalr-server::package'

# PuTTYgen (SSH Launcher support for Windows clients)
include_recipe 'scalr-server::puttygen'

# Runtime dependencies
include_recipe 'scalr-server::php'
include_recipe 'scalr-server::snmp'
include_recipe 'scalr-server::scalrpy'
include_recipe 'scalr-server::rrdcached'

# Scalr configuration and PHP settings
include_recipe 'scalr-server::configuration'
include_recipe 'scalr-server::php_settings'

# Database Configuration
include_recipe 'scalr-server::database_init_structure'
include_recipe 'scalr-server::database_init_admin'

# Set sysctl requirements
include_recipe 'scalr-server::sysctl'

# Service Configuration and Launch
include_recipe 'scalr-server::web'
include_recipe 'scalr-server::services'
include_recipe 'scalr-server::cron'

# Validate
include_recipe 'scalr-server::validate'
