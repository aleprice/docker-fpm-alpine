FROM arielkung/fpm-alpine

RUN apk add --no-cache --virtual .pecl-deps $PHPIZE_DEPS \
	&& pecl install xdebug \
	&& docker-php-ext-enable xdebug \
	&& apk del .pecl-deps
