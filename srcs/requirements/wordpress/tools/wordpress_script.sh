#!/bin/bash
set -eou pipefail
# Exit immediately if a command exits with a non-zero status (-e),
# treat unset variables as an error and exit immediately (-u),
# and prevent errors in a pipeline from being masked (-o pipefail).

MYSQL_USER=$(cat /run/secrets/mysql_user)
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WORDPRESS_ADMIN_EMAIL=$(cat /run/secrets/wordpress_admin_email)
WORDPRESS_USER=$(cat /run/secrets/wordpress_user)
WORDPRESS_PASSWORD=$(cat /run/secrets/wordpress_password)
WORDPRESS_EMAIL=$(cat /run/secrets/wordpress_email)

# Increase PHP memory limit to 512M
echo "memory_limit = 512M" >> /etc/php83/php.ini

# Function to log messages with timestamps
log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log "Starting WordPress setup!"

# Ensure PHP-FPM is installed and working
php-fpm83 -v || { log "ERROR: PHP-FPM is not installed or not working"; exit 1; }

# Ensure WP-CLI (WordPress Command Line Interface) is installed
if [ ! -f /usr/local/bin/wp ]; then
	log "WP-CLI is not installed. Installing WP-CLI..."
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	log "WP-CLI installation complete."
else
	log "WP-CLI is already installed."
fi

# Wait for MariaDB to be ready before proceeding
log "Waiting for MariaDB to be ready..."
until mariadb-admin ping --protocol=tcp --host=mariadb -u"$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>&1; do
	sleep 2
done
log "MariaDB is ready."

# Change to the WordPress installation directory
cd /var/www/html

# Check if WordPress is already installed
if [ ! -f wp-config.php ]; then
	log "WordPress is not installed. Starting installation process..."
	
	# Download and install WP-CLI (if not already done earlier)
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
		
	# Download WordPress core files
	wp core download --allow-root
	
	# Create the wp-config.php file with database credentials
	wp config create --allow-root --dbhost=mariadb --dbuser="$MYSQL_USER" \
		--dbpass="$MYSQL_PASSWORD" --dbname="$MYSQL_DATABASE"
	
	# Install WordPress with the provided admin credentials and site details
	wp core install --allow-root --skip-email --url="$DOMAIN_NAME" --title="Inception" \
		--admin_user="$WORDPRESS_ADMIN_USER" --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
		--admin_email="$WORDPRESS_ADMIN_EMAIL"

	# Create a new WordPress user if it doesn't already exist
	if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
		wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" --role=author --user_pass="$WORDPRESS_PASSWORD" --allow-root
		log "Created WordPress user '$WORDPRESS_USER'."
	fi

	log "WordPress installation complete."
else
	log "WordPress is already installed. Skipping installation."
fi

# Ensure the default theme (bedrock) is installed
if ! wp theme is-installed bedrock --allow-root > /dev/null 2>&1; then
	log "Default theme 'bedrock' is not installed. Installing theme..."
	wp theme install bedrock --allow-root
	log "Theme 'bedrock' installed."
fi

# Activate the default theme (bedrock)
log "Activating default theme 'bedrock'..."
wp theme activate bedrock --allow-root || { log "ERROR: Failed to activate theme 'bedrock'"; exit 1; }

# Set proper permissions for WordPress files and directories
log "Setting permissions for WordPress files..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/wp-content

# Start PHP-FPM in the foreground
log "Starting PHP-FPM..."
exec php-fpm83 -F
