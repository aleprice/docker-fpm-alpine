FROM arielkung/fpm-alpine

RUN set -xe \
  && apk add --no-cache --virtual .fetch-deps wget \
  && wget https://pecl.php.net/get/xdebug \
  && tar -xf xdebug \
  && mv xdebug-* /usr/src/php/ext/xdebug \
  && docker-php-ext-install xdebug \
  && apk del .fetch-deps 

