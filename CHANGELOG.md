v1.1.0
======

Added support for Scalr EE deployments through the Scalr installer.

Currently supported changes between OSS and EE are:

  + Scalarizr update configuration (in config.yml)
  + New SzrMessaging cron jobs (all 8 of them)
  + Database migrations

Caveats:

  + Need to identify a more reliable way to check database migrations are done

v1.0.1
======

Resolve manually the symlink for Selinux to solve a bug that prevented the
Chef run from completing multiple times.

v1.0.0
======

Support for deploys through git.
