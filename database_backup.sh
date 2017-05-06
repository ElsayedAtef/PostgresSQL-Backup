#! /bin/bash
#variable
TIMESTAMP=$(date +"%F-%H-%M")
BACKUP_DIR="/backup/Psotsql_dump/$TIMESTAMP"
#we use find to keep only 7 copies of databases
find  /backup/Postsql_dump/ -maxdepth 1 -type d -mtime +7 -exec rm -rf {} \;
mkdir -p "$BACKUP_DIR/"
#this command to list all database without database template0
databases=` sudo -i -u postgres  psql template1 -c "\l"|tail -n+4|cut -d'|' -f 1|sed -e '/^ *$/d'|sed -e '$d'|grep -iv "template0"`

#this command will take all databases from variable "databases" then enter to while to backup using pg_dump then make gzip to every database then  we use || to send email in case of backup fail
echo "$databases" | while read db; do
$(sudo -i -u postgres pg_dump  $db | gzip > "$BACKUP_DIR/$db.gz") || echo "$HOSTNAME database_dump backup failure" | mail -s "$HOSTNAME database_dump backup failure" mail@example.com
done
