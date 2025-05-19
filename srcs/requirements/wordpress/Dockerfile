# Use the official Alpine Linux image as the base image
FROM alpine:3.20.5

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Set the working directory inside the container
WORKDIR /var/www/html

# Update package index and install necessary packages:
# - bash: for scripting
# - curl: for downloading files
# - mariadb-client: for database interaction
# - php83 and related extensions: for running WordPress
RUN apk update && apk add --no-cache bash curl mariadb-client php83 php83-fpm \
	php83-phar php83-json php83-mysqli php83-curl php83-dom php83-mbstring \
	php83-openssl php83-xml php83-session

# Create a new group 'www-data' with GID 82 and a user 'www-data' with UID 82
# This is the standard user/group for web servers
RUN addgroup -g 82 www-data && adduser -u 82 -G www-data -s /bin/sh -D www-data || true

# Copy the PHP-FPM configuration file to the appropriate directory
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

# Copy the WordPress entrypoint script to the container's bin directory
COPY tools/wordpress_script.sh /usr/local/bin/

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/wordpress_script.sh

# Add a system user 'www-data' without a home directory or login shell
# This ensures the web server runs with minimal privileges
RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

# Set permissions for the working directory to allow the 'www-data' user to write
RUN chown -R 775 /var/www/html

# Verify that the PHP-FPM binary is installed and accessible
RUN which php-fpm83

# Set the entrypoint to the WordPress entrypoint script
ENTRYPOINT [ "wordpress_script.sh" ]


