#!/bin/bash
set -o errexit
set -o nounset

if [ "scalr-server" = "${1}" ]; then
  scalr-server-wizard
  scalr-server-ctl reconfigure

  service scalr stop
  sleep 15
  service scalr status && {
    echo "Supervisor did not exit!"
    exit 1
  }

  # Set path for supervisor
  PATH="/opt/scalr-server/embedded/scripts:${PATH}"
  PATH="/opt/scalr-server/embedded/bin:${PATH}"
  PATH="/opt/scalr-server/embedded/sbin:${PATH}"
  PATH="/opt/scalr-server/bin:${PATH}"
  export PATH

  set -- "/opt/scalr-server/embedded/bin/supervisord" \
         "--nodaemon" \
         "--configuration" \
         "/opt/scalr-server/etc/supervisor/supervisord.conf"
fi

echo "Exec: $@"
exec "$@"
