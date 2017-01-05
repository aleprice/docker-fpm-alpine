FROM php:fpm-alpine

RUN set -xe \
  && apk add --no-cache --virtual .fetch-deps zlib-dev py-setuptools wget bash \
  && docker-php-ext-install pdo_mysql opcache zip

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
	&& rm -fr /opt/newrelic \
	&& apk del .fetch-deps
