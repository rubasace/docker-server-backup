# docker-server-backup
Service in charge of backing up persistent volumes from containers

### Parameters Docker (Passed as Environment Variables)

| Name | Default | Description |  |
| ---- | ---- | ----------- | -------- |
| BACKUP_FILENAME | `docker-backup`  | Argument passed to the `sleep` command between executions of the script. **Only used if running via docker** | &nbsp; |

### Parameters (Passed as Environment Variables)

| Name | Default | Description |  |
| ---- | ---- | ----------- | -------- |
| DOCKER_COMPOSE_PATH | `INFO`  | Level that the logger will use. Can be set to DEBUG for troubleshooting. | &nbsp; |
| PERSISTENT_CONTAINERS_ROOT | `False`  | If `true` files that don't match any custom mapping will be moved to the `__default` folder. **This can mess up your folders** if you manually organized files that don't have custom formats.  | &nbsp; |
| BACKUP_DIRECTORY | `15m`  | Argument passed to the `sleep` command between executions of the script. **Only used if running via docker** | &nbsp; |
| BACKUP_NAME | `docker-backup`  | Argument passed to the `sleep` command between executions of the script. **Only used if running via docker** | &nbsp; |
| LOGFILE | `docker-backup`  | Argument passed to the `sleep` command between executions of the script. **Only used if running via docker** | &nbsp; |
| BACKUPS_TO_KEEP | `3`  | Argument passed to the `sleep` command between executions of the script. **Only used if running via docker** | &nbsp; |


### docker-compose: command not found
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose


rm -f $(ls -1td "/home/ruben/backup/docker-backup*" | tail -n +$((BACKUPS_TO_KEEP+1)))