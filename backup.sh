#!/usr/bin/env bash

#Internal Constants
DONT_STOP_CONFIG_FILE=dont-stop.txt
BACKUP_IGNORE_CONFIG_FILE=dont-backup.txt
LOGFILE="/home/ruben/docker/docker-server-backup/docker-backup.log"
DEFAULT_BACKUP_FILENAME="docker-backup"

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
    docker-compose -f ${DOCKER_COMPOSE_PATH} stop ${TO_STOP}

    declare IGNORED_FILES=$(cat ${BACKUP_IGNORE_CONFIG_FILE})
    echo "###### Backing up persistent volumes ######"
    echo "### Files that will not be backed up: ###"
    cat ${BACKUP_IGNORE_CONFIG_FILE}

    tar -cpzf ${BACKUP_DIRECTORY}/${BACKUP_FILENAME}_$(date +%F_%R).tar.gz --exclude-from=${BACKUP_IGNORE_CONFIG_FILE} ${PERSISTENT_CONTAINERS_ROOT}
    echo "###### Finished Backing up persistent volumes ######"
}

start_stopped_containers(){
    echo "###### Starting up stopped containers ######"
    docker-compose -f ${DOCKER_COMPOSE_PATH} up -d ${TO_STOP}
    echo "###### Finished starting up stopped containers ######"
}

echo "########## [`date +%F`T`date +%T`]  Starting Docker Server Backup with UID ${UID}##########"

start=`date +%s`

check_mandatory

#Configurable Properties
: "${BACKUP_FILENAME:=${DEFAULT_BACKUP_FILENAME}}"

#TODO dont stop containers without mounted volume on BACKUP_DIRECTORY
declare NOT_TO_STOP=$(cat ${DONT_STOP_CONFIG_FILE})

echo "###### Containers that will not be stopped: ######"
printf '%s\n' ${NOT_TO_STOP}

declare TO_STOP=$(docker-compose -f ${DOCKER_COMPOSE_PATH} ps --services | grep -v -x -F -f ${DONT_STOP_CONFIG_FILE})


(backup && start_stopped_containers) || (echo "[ERROR] Couldn't create a backup!!" && start_stopped_containers)

end=`date +%s`
runtime=$((end-start))
echo "########## [`date +%F`T`date +%T`] Finished Docker Server Backup in $runtime seconds ##########"

