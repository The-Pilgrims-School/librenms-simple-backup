#!/bin/bash
#
# Simple backup script for LibreNMS.
#
# Simply stops the Docker containers, backs up the folders (inc. the database now that the
# daemon is stopped) and then restarts them.
#
BACKUP_SOURCE=/var/librenms
BACKUP_STORAGE=/var/backups/librenms
DATE=$(date +%Y-%m-%d-%H-%M-%S)
KEEP=7

cd $BACKUP_SOURCE

# load configuration
. /etc/librenms-simple-backup.conf

function report_failure {
    payload=$(jq -n --arg text $1 '{"text":$text}' -cM)
    /usr/bin/curl -X POST -H 'Content-Type: application/json' -d "${payload}" $TEAMS_ALERT_ENDPOINT 
}

# bring down services
/usr/bin/docker-compose down
exitcode=$?
if [ $exitcode -ne 0 ]; then
    report_failure "$0: The docker-compose down process exited with $exitcode. Backup not started."
fi

# backup source directory while services are down
/usr/bin/tar --same-owner -cJpf $BACKUP_STORAGE/librenms_$DATE.tar.xz $BACKUP_SOURCE
exitcode=$?
if [ $exitcode -ne 0 ]; then
    report_failure "$0: The tar process exited with $exitcode. Backup may have not completed."
fi

# bring services back up
/usr/bin/docker-compose up -d
exitcode=$?
if [ $exitcode -ne 0 ]; then
    report_failure "$0: The docker-compose up process exited with $exitcode. The services may not have restarted."
fi

# tidy old backups
/usr/bin/find $BACKUP_STORAGE -type f -mtime +$KEEP -delete