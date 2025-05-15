#!/bin/bash
set -e

echo "I am executing mariaDB entrypoint script"

# Ensure the data directory exists
if [ ! -d "/var/lib/mysql" ]; then
    echo "Creating /var/lib/mysql directory"
    mkdir -p /var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "I am creating a new container for mariadb"
	mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql 
	mysqld --user=mysql --bootstrap << EOF


FLUSH PRIVILEGES;
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF
	echo "Initialization is complete"
fi

echo "MariaDB is starting"
exec mysqld --user=mysql