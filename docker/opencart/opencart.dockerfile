# Установка базового образа Ubuntu 18.04
FROM ubuntu:18.04

ENV TZ=Europe \
  # locale
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en
  #LC_ALL=en_US.UTF-8

#   Update php lib
RUN apt-get update && apt-get install -y software-properties-common wget unzip && add-apt-repository ppa:ondrej/php

## Installing php && modules
RUN apt-get install -y \
    php5.6 \
    php5.6-fpm \
    php5.6-mysql \
    php5.6-mcrypt \
    php5.6-dom \
    php5.6-xml \
    php5.6-curl \
    php5.6-gd \
    php5.6-mbstring


RUN apt-get install -y \
    php7.3 \
    php7.3-fpm \
    php7.3-mysql \
    php7.3-mcrypt \
    php7.3-dom \
    php7.3-xml \
    php7.3-curl \
    php7.3-gd \
    php7.3-mbstring


RUN apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-dom \
    php8.2-xml \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring


#CMD ["bash", "-c", "/var/www/opencart/install_opencart.sh"]
#CMD tail -f /dev/null

