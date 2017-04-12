FROM nginx:1.10

MAINTAINER Azavea

RUN mkdir -p /srv/dist && \
    chown nginx:nginx -R /srv/dist/

RUN mkdir -p /srv/static && \
    chown nginx:nginx -R /srv/static/

COPY srv/dist /srv/dist/
COPY srv/static /srv/static/
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
