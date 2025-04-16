FROM alpine:3.20

RUN apk add --no-cache nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY certs/ /etc/nginx/ssl/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
