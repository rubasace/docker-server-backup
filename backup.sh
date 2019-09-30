#!/usr/bin/env bash

SCRIPT_PATH="$(dirname -- "$0")"
#Internal Constants
DONT_STOP_CONFIG_FILE="${SCRIPT_PATH}"/dont-stop.txt
BACKUP_IGNORE_CONFIG_FILE="${SCRIPT_PATH}"/dont-backup.txt
LOGFILE="${SCRIPT_PATH}"/docker-backup.log
DEFAULT_BACKUP_NAME="docker-backup"
DEFAULT_BACKUPS_TO_KEEP=3

exec > >(tee ${LOGFILE}) 2>&1


check_mandatory(){
    if [ -z "${DOCKER_COMPOSE_PATH}" ] ; then
        echo "DOCKER_COMPOSE_PATH variable is mandatory. Aborting"
        exit 1
    fi

    if [ -z "${BACKUP_DIRECTORY}" ] ; then
        echo "BACKUP_DIRECTORY variable is mandatory. Aborting"
        exit 1
    fi

    if [ -z "${PERSISTENT_CONTAINERS_ROOT}" ] ; then
        echo "PERSISTENT_CONTAINERS_ROOT variable is mandatory. Aborting"
        exit 1
    fi
}

backup(){
    echo "###### Stopping containers: ######"
    docker-compose -f "${DOCKER_COMPOSE_PATH}" stop ${TO_STOP}

    echo "###### Backing up persistent volumes ######"

    if test -f "${BACKUP_IGNORE_CONFIG_FILE}"; then
        echo "### Files that will not be backed up: ###"
        cat ${BACKUP_IGNORE_CONFIG_FILE}
        tar -cpzf "${BACKUP_FILENAME}.tmp" --exclude-from=${BACKUP_IGNORE_CONFIG_FILE} "${PERSISTENT_CONTAINERS_ROOT}"
    else
        tar -cpzf "${BACKUP_FILENAME}.tmp" "${PERSISTENT_CONTAINERS_ROOT}"
    fi

    mv "${BACKUP_FILENAME}.tmp" "${BACKUP_FILENAME}"
    echo "###### Finished Backing up persistent volumes ######"
}

remove_old_backups(){
    echo "###### Removing old backups. Keeping last ${BACKUPS_TO_KEEP} ######"

    rm -f $(ls -1td ${BACKUP_DIRECTORY}/${BACKUP_NAME}* | tail -n +$((BACKUPS_TO_KEEP+1)))
    echo "###### Finished removing old backups ######"
}

start_stopped_containers(){
    echo "###### Starting up stopped containers ######"
    docker-compose -f "${DOCKER_COMPOSE_PATH}" up -d ${TO_STOP}
    echo "###### Finished starting up stopped containers ######"
}

echo "########## [`date +%F`T`date +%T`]  Starting Docker Server Backup with UID ${UID} ##########"

start=`date +%s`

check_mandatory

#Configurable Properties
: "${BACKUPS_TO_KEEP:=${DEFAULT_BACKUPS_TO_KEEP}}"
: "${BACKUP_NAME:=${DEFAULT_BACKUP_NAME}}"
BACKUP_FILENAME="${BACKUP_DIRECTORY}/${BACKUP_NAME}_$(date +%F_%R).tar.gz"

#TODO dont stop containers without mounted volume on BACKUP_DIRECTORY
if test -f "${DONT_STOP_CONFIG_FILE}"; then
    declare NOT_TO_STOP=$(cat ${DONT_STOP_CONFIG_FILE})
    echo "###### Containers that will not be stopped: ######"
    printf '%s\n' ${NOT_TO_STOP}
    declare TO_STOP=$(docker-compose -f "${DOCKER_COMPOSE_PATH}" ps --services | grep -v -x -F -f ${DONT_STOP_CONFIG_FILE})
else
    declare TO_STOP=$(docker-compose -f "${DOCKER_COMPOSE_PATH}" ps --services)
fi

(backup && start_stopped_containers) || (rm -f "${BACKUP_FILENAME}.tmp" && echo "[ERROR] Couldn't create a backup!!" && start_stopped_containers)

remove_old_backups

end=`date +%s`
runtime=$((end-start))
echo "########## [`date +%F`T`date +%T`] Finished Docker Server Backup in $runtime seconds ##########"
