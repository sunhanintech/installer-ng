#!/bin/bash
OPTS="-o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o StrictHostKeyChecking=no"
if [ -n "$GIT_SSH_KEY_PATH" ]; then
  OPTS="${OPTS} -i ${GIT_SSH_KEY_PATH}"
elif [ -n "$GIT_SSH_KEY_BODY" ]; then
  KEY_DIR=$(mktemp -d)
  trap "rm -rf $KEY_DIR" EXIT

  KEY_FILE="${KEY_DIR}/key"
  touch "${KEY_FILE}"
  chmod 600 -- "${KEY_FILE}"
  echo -n "${GIT_SSH_KEY_BODY}" > "${KEY_FILE}"

  OPTS="${OPTS} -i ${KEY_FILE}"
fi

ssh ${OPTS} "$@"
