FROM php:7.1-fpm-alpine

RUN set -xe \
  && apk add --no-cache py-setuptools git wget bash py-setuptools zlib-dev libpng-dev freetype-dev libjpeg-turbo-dev libmcrypt-dev libmemcached-dev icu-dev libxml2-dev \
  && apk add --no-cache libressl-dev cyrus-sasl-dev --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ rabbitmq-c-dev gnu-libiconv --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
  && mkdir -p /usr/src/php/ext \
  && wget https://pecl.php.net/get/memcached \
  && tar -xf memcached \
  && rm memcached \
  && mv memcached-* /usr/src/php/ext/memcached \
  && wget https://pecl.php.net/get/redis \
  && tar -xf redis \
  && rm redis \
  && mv redis-* /usr/src/php/ext/redis \
  && wget https://pecl.php.net/get/amqp \
  && tar -xf amqp \
  && rm amqp \
  && mv amqp-* /usr/src/php/ext/amqp \
  && wget https://pecl.php.net/get/igbinary \
  && tar -xf igbinary \
  && rm igbinary \
  && mv igbinary-* /usr/src/php/ext/igbinary \
  && wget https://pecl.php.net/get/apcu \
  && tar -xf apcu \
  && rm apcu \
  && mv apcu-* /usr/src/php/ext/apcu \
  && wget https://pecl.php.net/get/mcrypt \
  && tar -xf mcrypt \
  && rm mcrypt \
  && mv mcrypt-* /usr/src/php/ext/mcrypt \
  && git clone --recursive --depth=1 https://github.com/kjdev/php-ext-snappy.git \
  && mv php-ext-snappy /usr/src/php/ext/snappy \
  && docker-php-ext-install pdo_mysql opcache zip pcntl mcrypt iconv soap intl xml amqp igbinary redis snappy apcu \
  && docker-php-ext-configure memcached --enable-memcached-igbinary --disable-memcached-sasl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd memcached \ 
  && echo 'extension = "apcu.so"' > /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
  && echo 'apc.shm_size = 256M' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN wget https://bootstrap.pypa.io/get-pip.py \
	&& python get-pip.py --no-setuptools --no-wheel \
	&& rm get-pip.py

RUN mkdir -p /opt/newrelic
WORKDIR /opt/newrelic
RUN wget -r -nd --no-parent -Alinux-musl.tar.gz \
	http://download.newrelic.com/php_agent/release/ >/dev/null 2>&1 \
	&& tar -xzf newrelic-php*.tar.gz --strip=1 \
	&& rm newrelic-php*.tar.gz
ENV NR_INSTALL_SILENT true
ENV NR_INSTALL_PHPLIST /usr/local/bin/
RUN bash newrelic-install install
WORKDIR /
RUN pip install newrelic-plugin-agent \
	&& mkdir -p /var/log/newrelic \
	&& mkdir -p /var/run/newrelic

RUN cp /opt/newrelic/agent/x64/newrelic-20160303.so /usr/local/lib/php/extensions/no-debug-non-zts-20160303/newrelic.so \
        && echo 'extension = "newrelic.so"' > /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo '[newrelic]' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo 'newrelic.enabled = true' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo 'newrelic.license = ${NEWRELIC_LICENSE}' >> /usr/local/etc/php/conf.d/newrelic.ini \
 	&& echo 'newrelic.appname = ${NEWRELIC_APPNAME}' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& echo 'newrelic.feature_flag=laravel_queue' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& rm -fr /opt/newrelic \
  && rm -fr /usr/src/php/ext \
	&& apk del git py-setuptools wget bash 

RUN echo 'memory_limit = 512M' > /usr/local/etc/php/conf.d/settings.ini \
  && sed -i "s/access.log =.*/access.log = \/proc\/self\/fd\/1/" /usr/local/etc/php-fpm.d/docker.conf

WORKDIR /var/www/html
