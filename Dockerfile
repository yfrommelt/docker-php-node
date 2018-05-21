FROM php:7.2-fpm

MAINTAINER Yoann Frommelt <yfrommelt@hevaweb.com>

# Set correct environment variables.
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /root

# Ubuntu mirrors
RUN apt-get update

# Repo for Yarn
RUN apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Repo for Node
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

# Install requirements for standard builds.
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        apt-transport-https \
        build-essential \
        bzip2 \
        ca-certificates \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libpng12-dev \
        libpq-dev \
        libssl-dev \
        libz-dev \
        nodejs \
        openssh-client \
        rsync \
        unzip \
        wget \
        yarn \
        zlib1g-dev

# Standard cleanup
RUN apt-get autoremove -y && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install common PHP packages.
RUN docker-php-ext-install \
    iconv \
    mcrypt \
    mbstring \
    bcmath \
    intl \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    zip

# Install the PHP gd library
RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

# Install Xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug
COPY xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php
COPY composer.phar /usr/local/bin/composer

# Add fingerprints for common sites.
RUN mkdir ~/.ssh && \
    ssh-keyscan -H github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -H gitlab.com >> ~/.ssh/known_hosts

# Show versions
RUN php -v && \
    node -v && \
    npm -v && \
    yarn -v

CMD ["bash"]