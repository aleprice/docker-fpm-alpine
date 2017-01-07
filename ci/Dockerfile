FROM arielkung/fpm-alpine

RUN wget --no-check-certificate https://pecl.php.net/get/xdebug \
  && tar -xf xdebug \
  && mv xdebug-* /usr/src/php/ext/xdebug
  && docker-php-ext-install xdebug

