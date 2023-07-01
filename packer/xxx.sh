#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

echo "Beginning of shell xxx"

sudo mkdir -p /home/ns

echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
sudo apt-get install -y -q

echo "sleeping 10"
sleep 10

echo "Apt updating"
sudo apt-get update -y

echo "sleeping 15"
sleep 15

echo "installing policykit-1"
sudo apt-get install -y policykit-1

echo "installing htop"
sudo apt-get install -y htop

echo "installing other packages"
sudo apt-get update \
    && apt-get install -y \
      build-essential \
      software-properties-common \
      wget \
      autoconf \
      cron \
      iputils-ping \
      dpkg-dev \
      zip \
      unzip \
      curl \
      rsync \
      ntp \
      git \
      ssh \
      nano \
      net-tools \
      libpng-dev \
      libicu-dev \
      libxml2-dev \
      libpq-dev \
      libjpeg-dev \
      libfreetype6-dev \
      libssl-dev \
      libzip-dev \
      libmcrypt-dev \
      libwebp-dev \
      libgd-dev \
      libxpm-dev \
      zlib1g-dev

echo "sleeping 10"
sleep 10

echo "installing ppa:ondrej/php php7.3"

sudo add-apt-repository ppa:ondrej/php \
    && sudo apt-get update \
    && sudo apt-get install -y \
    php7.3-fpm \
    php7.3-cli \
    php7.3-gd \
    php7.3-intl \
    php7.3-zip \
    php7.3-mysqli \
    php7.3-pdo \
    php7.3-mbstring \
    php7.3-exif \
    php7.3-bcmath \
    php7.3-xml \
    php7.3-ldap \
    php7.3-sockets \
    php7.3-opcache \
    php7.3-curl \
    php7.3-dev \
    php-pear \
    php7.3-gmp \
    php7.3-soap 

echo "sleeping 10"
sleep 10

echo "Downloading and Installing Aerospike library"
sudo mkdir -p /usr/lib/php/20170718/ && sudo mkdir -p /tmp/aero && sudo curl -o /tmp/aero.tar -L https://github.com/aerospike/aerospike-client-php/archive/refs/tags/7.5.2.tar.gz && sudo tar -xzvf /tmp/aero.tar -C /tmp/aero  && sudo cd /tmp/aero/aerospike-client-php-7.5.2/src && sudo bash ./build.sh && make install

echo "extension=aerospike.so\n\
aerospike.udf.lua_user_path=/usr/local/aerospike/usr-lua" > "/etc/php/7.3/mods-available/aerospike.ini"


echo "Adding symbolic links for aerospike.ini"
ln -s /etc/php/7.3/mods-available/aerospike.ini /etc/php/7.3/fpm/conf.d/20-aerospike.ini \
    && ln -s /etc/php/7.3/mods-available/aerospike.ini /etc/php/7.3/cli/conf.d/20-aerospike.ini

echo "[OK] All done!"