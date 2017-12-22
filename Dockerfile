FROM php:7.2-fpm-alpine

# docker-entrypoint.sh dependencies
RUN apk add --no-cache \
# in theory, docker-entrypoint.sh is POSIX-compliant, but priority is a working, consistent image
		bash \
# BusyBox sed is not sufficient for some of our sed expressions
		sed

# install the PHP extensions we need
RUN set -ex; \
	\
	apk add --no-cache --virtual .build-deps \
		autoconf \
	; \
	\
	docker-php-ext-install opcache; \
	pecl install memcached-3.0.4 && \
	docker-php-ext-enable memcached; \
	apk del .build-deps

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

VOLUME /var/www/html

ENV MPOS_VERSION 1.0.8
ENV MPOS_SHA1 994fd4733ce2f8e93816ff384e21c2a1773b8552

RUN set -ex; \
	curl -o mpos.tar.gz -fSL "https://github.com/MPOS/php-mpos/archive/v${MPOS_VERSION}.tar.gz"; \
	echo "$MPOS_SHA1 *mpos.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./mpos/ so this gives us /usr/src/mpos
	tar -xzf mpos.tar.gz -C /usr/src; \
	rm mpos.tar.gz; \
	mv "/usr/src/php-mpos-${MPOS_VERSION}" /usr/src/mpos; \
	chown -R www-data:www-data /usr/src/mpos

ADD global.inc.php /var/www/mpos/include/config/global.inc.php

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
