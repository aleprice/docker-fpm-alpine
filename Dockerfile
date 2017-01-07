FROM php:fpm-alpine

RUN set -xe \
  && apk add --no-cache --virtual .fetch-deps zlib-dev py-setuptools wget bash libpng-dev freetype-dev libjpeg-turbo-dev libmcrypt-dev libmemcached-dev icu-dev libxml2-dev libressl-dev --repository http://dl-3.alpinelinux.org/alpine/edge/main/ rabbitmq-c-dev --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
  && wget --no-check-certificate https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz \
  && tar -xf php7.tar.gz \
  && mv php-memcached-php7 /usr/src/php/ext/memcached \
  && wget https://pecl.php.net/get/redis-3.1.0.tgz \
  && tar -xf redis-3.1.0.tgz \
  && mv redis-3.1.0 /usr/src/php/ext/redis \
  && wget https://pecl.php.net/get/amqp-1.7.1.tgz \
  && tar -xf amqp-1.7.1.tgz \
  && mv amqp-1.7.1 /usr/src/php/ext/amqp \
  && wget https://pecl.php.net/get/igbinary-2.0.1.tgz \
  && tar -xf igbinary-2.0.1.tgz \
  && mv igbinary-2.0.1 /usr/src/php/ext/igbinary \
  && docker-php-ext-configure memcached --enable-memcached-igbinary --disable-memcached-sasl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd pdo_mysql opcache zip pcntl mcrypt iconv soap intl xml memcached amqp igbinary redis

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
	&& echo 'newrelic.appname = ${NEWRELIC_APPNAME}${NEWRELIC_APPNAME}' >> /usr/local/etc/php/conf.d/newrelic.ini \
	&& rm -fr /opt/newrelic \
	&& apk del .fetch-deps .fetch-testing-deps
	
WORKDIR /var/www/html
