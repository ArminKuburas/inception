# Use the penultimate version of Alpine
FROM alpine:3.20.6

# Expose the default Mariadb port
EXPOSE 3306

# Update the package list and install MariaDB and its client
RUN apk update && apk add mariadb mariadb-client mariadb-common bash

# Copy the entrypoint script and the configuration file
COPY tools/mariadb_script.sh /usr/local/bin/
COPY ./conf/mariadb.cnf /etc/my.cnf.d/mariadb.cnf

# Change the permissions of the entrypoint script to be executable by all users
# Make directories for MySQL data, run, and log
# Change the ownership of the MySQL data, run, and log directories to the MySQL user
RUN chmod +x /usr/local/bin/mariadb_script.sh && \
	mkdir -p /var/lib/mysql /var/run/mysqld /var/log/mysql && \
	chown -R mysql:mysql /var/lib/mysql /var/run/mysqld /var/log/mysql

ENTRYPOINT [ "mariadb_script.sh" ]