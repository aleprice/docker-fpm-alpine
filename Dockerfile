FROM php:fpm-alpine

RUN set -xe \
  && apk add --no-cache --virtual .fetch-deps zlib-dev py-setuptools wget bash libpng-dev freetype-dev libjpeg-turbo-dev libmcrypt-dev libmemcached-dev icu-libs \
  && docker-php-ext-install pdo_mysql opcache zip pcntl mcrypt iconv soap intl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && apk add --no-cache --virtual rabbitmq-c-dev --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
  && printf "\n" | pecl install memcached amqp igbinary redis \
  && docker-php-ext-enable memcached amqp igbinary redis

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
	&& rm -fr /opt/newrelic \
	&& apk del .fetch-deps
	
WORKDIR /var/www/html
