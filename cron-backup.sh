#!/usr/bin/env bash

SCRIPT_PATH="$(dirname -- "$0")"

${SCRIPT_PATH}/backup.sh
${SCRIPT_PATH}/update-backup.sh
