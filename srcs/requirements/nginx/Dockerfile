
FROM alpine:3.20.5

RUN apk update && \
	apk add nginx openssl

EXPOSE 443

COPY tools/generate_certs.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate_certs.sh

RUN mkdir -p /run/nginx /etc/nginx/ssl

RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN chmod 644 /etc/nginx/nginx.conf

ENTRYPOINT [ "generate_certs.sh" ]
