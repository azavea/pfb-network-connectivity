FROM node:12.19-buster-slim

ENV BASE_DIR /opt/pfb/tilegarden

# Quick fix for EOL Debian "Buster"
# This command updates the sources.list to point to the archive before installing
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list && \
    apt-get update -y && apt-get install -y git jq python2 && apt-get clean
RUN yarn global add carto

# Copy files needed for installing packages first
COPY package.json yarn.lock ${BASE_DIR}/
WORKDIR ${BASE_DIR}/

# install node modules
RUN yarn install

# Copy remaining files after package installation to benefit from layer caching
COPY . ${BASE_DIR}/

CMD ["yarn", "dev"]
