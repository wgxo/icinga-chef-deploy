#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Use: $0 DATE FILE [FILE ...]"
    exit 1
fi

BACKUP_DIR="/opt/backups"
DATE="$1"

shift

### BEGIN LOGS BACKUP ###

# compress files before moving them
chmod 644 `for f in $*; do echo $f-${DATE}; done`
gzip `for f in $*; do echo $f-${DATE}; done`

if [ $? != 0 ]; then
  echo "gzip exited abnormally. Backup stopped"
  exit 1
fi

for FILE in $*; do
    # Move logs to backup dir
    cp ${FILE}-${DATE}.gz ${BACKUP_DIR}/ 2>&1
done

# decompress files before deleting them
gunzip `for f in $*; do echo $f-${DATE}.gz; done`

### END LOGS BACKUP ###


exit 0
