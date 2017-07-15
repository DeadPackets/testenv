#!/usr/bin/env bash

# Wait for database to get available
MYSQL_LOOPS="20"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"

# Wait for mysql
service mysql start

i=0
while ! nc ${MYSQL_HOST} ${MYSQL_PORT} >/dev/null 2>&1 < /dev/null; do
  i=`expr $i + 1`
  if [ ${i} -ge ${MYSQL_LOOPS} ]; then
    echo "$(date) - ${MYSQL_HOST}:${MYSQL_PORT} still not reachable, giving up"
    exit 1
  fi
  echo "$(date) - waiting for ${MYSQL_HOST}:${MYSQL_PORT}..."
  sleep 1
done


echo "Create the database"
mysql -u root -h ${MYSQL_HOST} < /var/www/sqlmap/schema/mysql.sql


echo "Start apache"
# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid
service apache2 start
