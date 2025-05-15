#!/bin/bash
set -e

echo "memory_limit = 512M" >> /etc/php83/php.ini

echo "Starting wordpress setup!"

# Ensure PHP-FPM is installed
php-fpm83 -v || { echo "PHP-FPM is not installed or not working"; exit 1; }

# Ensure WP-CLI is installed
if [ ! -f /usr/local/bin/wp ]; then
	echo "WP-CLI is not installed. Installing now."
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
else
	echo "WP-CLI is already installed."
fi

# Waiting for mariaDB to set up
until mariadb-admin ping --protocol=tcp --host=mariadb -u"$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>&1; do                                    
	sleep 2                                                                                                                                                       
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
   	echo "Wordpress not installed. Installing now."
	
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	    
	wp core download --allow-root
        wp config create --allow-root --dbhost=mariadb --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" --dbname="$MYSQL_DATABASE"
        wp core install --allow-root  --skip-email  --url="$DOMAIN_NAME"  --title="Inception" \
            --admin_user="$WORDPRESS_ADMIN_USER"  --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL"

        if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
            wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=author --user_pass="$WORDPRESS_PASSWORD" --allow-root
        fi

	echo "Wordpress installation complete."
else
	echo "WordPress was already installed."
fi

# Ensure the default theme is installed and activated
if ! wp theme is-installed bedrock --allow-root > /dev/null 2>&1; then
	echo "Installing default theme 'bedrock'..."
	wp theme install bedrock --allow-root
fi

echo "Activating default theme 'bedrock'..."
wp theme activate bedrock --allow-root || { echo "Failed to activate theme 'bedrock'"; exit 1; }

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/wp-content

echo "Starting up PHP-FPM"
exec php-fpm83 -F
