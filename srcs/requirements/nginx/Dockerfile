
# Make sure to use the penultimate version of Alpine
FROM alpine:3.20.6

# Update the package list and install Nginx and OpenSSL
# Create necessary directories and add a non-root user
# The non-root user is created with the same UID and GID as the host user
# This is to avoid permission issues when mounting volumes
# The user is added to the www-data group, which is the group that Nginx runs as
# The user is created with the -D flag to avoid creating a home directory
# The user is created with the -H flag to avoid creating a password
# The user is created with the -s flag to set the shell to /sbin/nologin
# The user is created with the -g flag to set the group to www-data
# The user is created with the -G flag to set the supplementary group to www-data

RUN apk update && \
    apk add nginx openssl && \
    mkdir -p /run/nginx /etc/nginx/ssl && \
    adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

# Copy the entrypoint script
COPY tools/nginx_script.sh /usr/local/bin/
# Change the permissions of the entrypoint script to be executable by all users
RUN chmod 700 /usr/local/bin/nginx_script.sh

# Copy the Nginx configuration file
# Change the permissions of the Nginx configuration file to be readable by all users
COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN chmod 600 /etc/nginx/nginx.conf

# Expose the HTTP and HTTPS ports
EXPOSE 443

ENTRYPOINT [ "nginx_script.sh" ]
