FROM php:5.6-fpm-alpine

RUN set -xe \
  && apk add --no-cache py-setuptools git wget bash py-setuptools zlib-dev libpng-dev freetype-dev libjpeg-turbo-dev libmcrypt-dev libmemcached-dev icu-dev libxml2-dev \
  && apk add --no-cache libressl-dev cyrus-sasl-dev --repository http://dl-3.alpinelinux.org/alpine/edge/main/ rabbitmq-c-dev --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
  && mkdir -p /usr/src/php/ext \
  && wget https://pecl.php.net/get/memcached \
  && tar -xf memcached \
  # && rm memcached \
  # && mv memcached-* /usr/src/php/ext/memcached \
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
  && git clone --recursive --depth=1 https://github.com/kjdev/php-ext-snappy.git \
  && mv php-ext-snappy /usr/src/php/ext/snappy \
  && docker-php-ext-install mysql pdo_mysql opcache zip pcntl mcrypt iconv soap intl xml amqp igbinary redis snappy \
  # && docker-php-ext-configure memcached --enable-memcached-igbinary --disable-memcached-sasl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
  # && docker-php-ext-install gd memcached

RUN rm -fr /usr/src/php/ext \
	&& apk del git py-setuptools wget bash 

RUN echo 'memory_limit = 512M' > /usr/local/etc/php/conf.d/settings.ini \
  && sed -i "s/access.log =.*/access.log = \/proc\/self\/fd\/1/" /usr/local/etc/php-fpm.d/docker.conf

WORKDIR /var/www/html
