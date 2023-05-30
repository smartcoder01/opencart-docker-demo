FROM php:5.6-fpm

WORKDIR /var/www/opencart

# timezone environment
ENV TZ=UTC \
  # locale
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US:en \
  LC_ALL=en_US.UTF-8

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions intl pdo_mysql mysql mysqli gd zip pcntl bcmath mcrypt


RUN apt-get update \
  && apt-get -y install --no-install-recommends \
    libcurl4-openssl-dev pkg-config libssl-dev \
    locales \
    git \
    wget \
    unzip \
    libzip-dev \
    libicu-dev \
    libonig-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8 \
  && localedef -f UTF-8 -i en_US en_US.UTF-8

COPY ./docker/php/5.6/php.deploy.ini /usr/local/etc/php/php.ini

# start PHP-FPM
CMD ["php-fpm"]
