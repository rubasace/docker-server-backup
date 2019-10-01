#!/usr/bin/env bash

SCRIPT_PATH="$(dirname -- "$0")"

LOGFILE="${SCRIPT_PATH}"/cron-backup.log

exec > >(tee ${LOGFILE}) 2>&1

#${SCRIPT_PATH}/backup.sh
${SCRIPT_PATH}/update-backup.sh
