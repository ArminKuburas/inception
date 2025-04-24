#!/bin/bash

if [ ! -f "../../.env" ]; then
    echo "Creating .env file..."
    cat <<EOT > ../../.env
DOMAIN_NAME=armin.42.fr
EOT
    echo ".env file created."
else
    echo ".env file already exists."
fi

# Check if certificates exist
CERTS_DIR="../../certs"
if [ ! -f "$CERTS_DIR/fullchain.pem" ] || [ ! -f "$CERTS_DIR/privkey.pem" ]; then
    echo "Generating SSL certificates..."
    mkdir -p $CERTS_DIR
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$CERTS_DIR/privkey.pem" -out "$CERTS_DIR/fullchain.pem" -subj "/CN=armin.42.fr"
    echo "SSL certificates generated."
else
    echo "SSL certificates already exist."
fi
