# Use the penultimate stable version of Alpine
# https://alpinelinux.org/releases/
FROM alpine:3.20

# Install PHP and extensions
RUN apk add --no-cache php php-fpm php-mysqli php-curl php-xml php-mbstring php-gd

# Copy WordPress files
COPY conf/php-fpm.conf /etc/php8/php-fpm.conf
COPY conf/www.conf /etc/php8/php-fpm.d/www.conf
COPY conf/php.ini /etc/php8/php.ini

# Create WordPress directory
RUN mkdir -p /var/www/html

# Expose port 9000
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm8"]
