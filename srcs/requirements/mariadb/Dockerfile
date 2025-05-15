FROM alpine:3.20.5

EXPOSE 3306

RUN apk update && apk add mariadb mariadb-client mariadb-common bash

COPY tools/mariadb_script.sh /usr/local/bin/
COPY ./conf/mariadb.cnf /etc/my.cnf.d/mariadb.cnf

RUN chmod +x /usr/local/bin/mariadb_script.sh

RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
RUN mkdir -p /var/log/mysql && chown -R mysql:mysql /var/log/mysql

ENTRYPOINT [ "mariadb_script.sh" ]