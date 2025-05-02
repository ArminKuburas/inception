#!/bin/bash
set -e

echo "Starting WordPress setup!"

# Ensure PHP-FPM is installed and working
php-fpm83 -v || { echo "PHP-FPM is not installed or not working"; exit 1; }

# Wait for MariaDB to be ready
until mariadb-admin ping --protocol=tcp --host=mariadb -u"$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>&1; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
done

cd /var/www/html

# Set memory limit in php.ini
echo "memory_limit = 512M" >> /etc/php83/php.ini

# Install WordPress if not already installed
if [ ! -f wp-config.php ]; then
    echo "WordPress not installed. Installing now."

    # Download and install WP-CLI
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # Download WordPress core files
    wp core download --allow-root

    # Create WordPress configuration file
    wp config create --allow-root --dbhost=mariadb --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" --dbname="$MYSQL_DATABASE"

    # Install WordPress
    wp core install --allow-root --skip-email --url="$DOMAIN_NAME" --title="Inception" \
        --admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL"

    # Create a second user if it doesn't exist
    if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
        wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=author --user_pass="$WORDPRESS_PASSWORD" --allow-root
    fi

    echo "WordPress installation complete."
else
    echo "WordPress was already installed."
fi

# Set correct ownership and permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/wp-content

echo "Starting up PHP-FPM"
exec php-fpm83 -F
