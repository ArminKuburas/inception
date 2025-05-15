#!/bin/sh

# This script is used to generate SSL certificates and configure Nginx
# with the provided environment variables. It also replaces placeholders
# in the nginx configuration file with the actual values.
# It is designed to be run as part of a Docker container entrypoint.
# Ensure that the script is executed with the correct permissions
# and that the necessary environment variables are set.

DOMAIN_NAME=${DOMAIN_NAME:-localhost}
SSL_CERTIFICATE=${SSL_CERTIFICATE:-/etc/nginx/ssl/default.crt}
KEY_PATH=${KEY_PATH:-/etc/nginx/ssl/default.key}

# Function to log messages with timestamps
log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Log the environment variables to check if they are set correctly
log "DOMAIN_NAME: $DOMAIN_NAME"
log "SSL_CERTIFICATE: $SSL_CERTIFICATE"
log "KEY_PATH: $KEY_PATH"

# Ensure the required environment variables are set
if [ -z "$DOMAIN_NAME" ]; then
	log "Error: DOMAIN_NAME is not set."
	exit 1
fi
if [ -z "$SSL_CERTIFICATE" ]; then
	log "Error: SSL_CERTIFICATE is not set."
	exit 1
fi
if [ -z "$KEY_PATH" ]; then
	log "Error: KEY_PATH is not set."
	exit 1
fi

if [ ! -f "$SSL_CERTIFICATE" ] || [ ! -f "$KEY_PATH" ]; then
	log "SSL certificate or key not found. Generating new ones..."

	# Generate SSL certificate and key
	openssl req -newkey rsa:2048 -x509 -sha256 -days 365 -nodes \
		-out "$SSL_CERTIFICATE" \
		-keyout "$KEY_PATH" \
		-subj "/CN=${DOMAIN_NAME:-localhost}" || {
		log "Failed to generate SSL certificate and key."; exit 1;}

	log "SSL certificate and key generated."
fi

# Replace placeholders in nginx.conf with environment variables
sed -i "s|DOMAIN_NAME|$DOMAIN_NAME|g" /etc/nginx/nginx.conf || { log "Failed to replace DOMAIN_NAME in nginx.conf"; exit 1; }
sed -i "s|SSL_CERTIFICATE|$SSL_CERTIFICATE|g" /etc/nginx/nginx.conf || { log "Failed to replace SSL_CERTIFICATE in nginx.conf"; exit 1; }
sed -i "s|KEY_PATH|$KEY_PATH|g" /etc/nginx/nginx.conf || { log "Failed to replace KEY_PATH in nginx.conf"; exit 1; }

# Log the updated nginx.conf
log "nginx.conf after substitution:"
cat /etc/nginx/nginx.conf

# Start Nginx with the custom configuration
log "Starting Nginx..."
exec nginx -c /etc/nginx/nginx.conf -g "daemon off;"