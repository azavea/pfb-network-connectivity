FROM node:6.9.5-wheezy

MAINTAINER Azavea

ENV ANGULAR_DIR /opt/pfb/angular

RUN apt-get update && apt-get install -y rsync \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g bower gulp

WORKDIR /opt/pfb/angular
COPY angular/package.json ${ANGULAR_DIR}/package.json
RUN npm install

COPY angular/bower.json ${ANGULAR_DIR}/bower.json
COPY angular/.bowerrc ${ANGULAR_DIR}/.bowerrc
RUN bower install --allow-root --config.interactive=false

COPY angular/.eslintrc ${ANGULAR_DIR}/.eslintrc
COPY angular/gulp ${ANGULAR_DIR}/gulp
COPY angular/src ${ANGULAR_DIR}/src

COPY angular/gulpfile.js ${ANGULAR_DIR}/gulpfile.js

RUN gulp build
