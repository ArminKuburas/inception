# Use the penultimate stable version of Alpine
# https://alpinelinux.org/releases/
FROM alpine:3.20 
# Install MariaDB
RUN apk add --no-cache mariadb mariadb-client

# Copy MariaDB configuration files
COPY conf/my.cnf /etc/my.cnf

# Create database directory
RUN mkdir -p /var/lib/mysql

# Expose port 3306
EXPOSE 3306

# Start MariaDB
CMD ["mysqld"]
