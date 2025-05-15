FROM alpine:3.20.5

EXPOSE 9000

WORKDIR /var/www/html

RUN apk update && apk add --no-cache bash curl mariadb-client php83 php83-fpm \
	php83-phar php83-json php83-mysqli php83-curl php83-dom php83-mbstring \
	php83-openssl php83-xml php83-session

RUN addgroup -g 82 www-data && adduser -u 82 -G www-data -s /bin/sh -D www-data || true

COPY conf/www.conf /etc/php83/php-fpm.d/www.conf

COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

RUN chown -R 775 /var/www/html

RUN which php-fpm83

ENTRYPOINT [ "wordpress-entrypoint.sh" ]


