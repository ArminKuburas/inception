#!/bin/bash

# Set the shell options to exit immediately if a command fails,
# treat unset variables as an error, and pipe failures as errors
# This is a best practice for writing robust shell scripts.
# It helps to catch errors early and makes debugging easier.
# The script is designed to be run as part of a Docker container entrypoint.
set -euo pipefail

MYSQL_USER=$(cat /run/secrets/mysql_user)
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_DATABASE=${MYSQL_DATABASE:-wordpress}



log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

log "Starting MariaDB setup!"

# Check if the mysql directory exists
# If it doesn't exist, create it and set the ownership to mysql:mysql
# Although the dockerfile already creates the directory, this is a safety check
# to ensure that the directory is present before proceeding with the initialization
if [ ! -d "/var/lib/mysql" ]; then
    log "I am creating a new container for mariadb. Creating /var/lib/mysql directory."
    mkdir -p /var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
	log "Downl"
	mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql 
	mysqld --user=mysql --bootstrap << EOF


FLUSH PRIVILEGES;
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
	log "MariaDB setup complete."
fi
log "Starting MariaDB server..."
# Start the MariaDB server with the specified user
exec mysqld --user=mysql