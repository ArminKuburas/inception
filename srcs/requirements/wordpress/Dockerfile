# srcs/requirements/wordpress/Dockerfile
FROM alpine:3.20.6

EXPOSE 9000

WORKDIR /var/www/html

# Install necessary packages
RUN apk update && apk add --no-cache bash curl mariadb-client php83 php83-fpm \
    php83-phar php83-json php83-mysqli php83-curl php83-dom php83-mbstring \
    php83-openssl php83-xml php83-session

# Create www-data user and group
RUN addgroup -g 82 www-data && adduser -u 82 -G www-data -s /bin/sh -D www-data || true

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

# Copy entrypoint script
COPY tools/wordpress-entrypoint.sh /usr/local/bin/

# Make entrypoint script executable
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

# Ensure correct ownership of the WordPress directory
RUN chown -R 775 /var/www/html

# Verify PHP-FPM installation
RUN which php-fpm83

# Set the entrypoint
ENTRYPOINT ["wordpress-entrypoint.sh"]

