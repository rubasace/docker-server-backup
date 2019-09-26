#!/usr/bin/env bash

#Internal Constants
DONT_STOP_CONFIG_FILE=dont-stop.txt
BACKUP_IGNORE_CONFIG_FILE=backup-ignore.txt

#Configurable Properties
DOCKER_COMPOSE_PATH="/home/ruben/nas/docker-compose.yml"
PERSISTENT_CONTAINERS_ROOT="/home/ruben/docker"
BACKUP_DIRECTORY="/home/ruben/backup-script"
BACKUP_FILENAME="docker"

echo "########## Starting Docker Server Backup ##########"

start=`date +%s`

declare NOT_TO_STOP=$(cat ${DONT_STOP_CONFIG_FILE})

echo "###### Containers that will not be stopped: ######"
printf '%s\n' ${NOT_TO_STOP}

declare TO_STOP=$(docker ps --format '{{.Names}}' | grep -v -x -F -f ${DONT_STOP_CONFIG_FILE})

echo "###### Containers that will be stopped: ######"
printf '%s\n' ${TO_STOP}

echo "###### Stopping containers: ######"
docker-compose -f $DOCKER_COMPOSE_PATH stop $TO_STOP

declare IGNORED_FILES=$(cat ${BACKUP_IGNORE_CONFIG_FILE})
echo "###### Backing up persistent volumes ######"
echo "### Files that will not be backed up: ###"
printf '%s\n' ${IGNORED_FILES}

sudo tar -cvpzf ${BACKUP_DIRECTORY}/${BACKUP_FILENAME}_$(date +%F_%R).tar.gz --exclude-from=${BACKUP_IGNORE_CONFIG_FILE} ${PERSISTENT_CONTAINERS_ROOT}
echo "###### Finished Backing up persistent volumes ######"

echo "###### Starting up stopped containers ######"
docker-compose -f ${DOCKER_COMPOSE_PATH} up -d
echo "###### Finished starting up stopped containers ######"

end=`date +%s`
runtime=$((end-start))
echo "########## Finished Docker Server Backup in $runtime seconds ##########"

