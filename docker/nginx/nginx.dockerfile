FROM nginx:1.22

WORKDIR /var/www/opencart

ENV TZ=UTC

COPY ./docker/nginx/*.conf /etc/nginx/conf.d/
