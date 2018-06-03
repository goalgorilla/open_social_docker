FROM php:7.2-fpm-alpine

# install the PHP extensions we need
# postgresql-dev is needed for https://bugs.alpinelinux.org/issues/3642
RUN set -ex \
    && apk update \
	&& apk add --no-cache --virtual .build-deps \
		coreutils \
		freetype-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		postgresql-dev \
		mysql-client \
		rsyslog \
	    bash \
	    ssmtp \
	    bash-completion \
	    nano \
	    vim \
	    git \
	&& docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
	&& docker-php-ext-install -j "$(nproc)" gd mbstring opcache pdo pdo_mysql pdo_pgsql exif \
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --virtual .drupal-phpexts-rundeps $runDeps

# Install Xdebug.
#RUN apk add --no-cache $PHPIZE_DEPS \
#    && pecl install -f xdebug-2.6.0 \
#    && docker-php-ext-enable xdebug

# Remove install and temp files.
RUN rm -rf /var/cache/apk/* && rm -rf /tmp/*

# Add custom PHP settings.
ADD default.ini /usr/local/etc/php/conf.d/
ADD mail.conf /etc/ssmtp/ssmtp.conf
ADD mail.ini /usr/local/etc/php/conf.d/mail.ini

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# Install Drush.
RUN composer global require drush/drush:8.* \
    && rm -f /usr/local/bin/drush \
    && ln -s ~/.composer/vendor/bin/drush /usr/local/bin/drush \
    && drush core-status -y

# Install Open Social via Composer.
#WORKDIR /var/www/
#ADD composer.json /var/www/composer.json
#RUN rm -f /var/www/composer.lock \
#    && composer install --prefer-dist --no-interaction --no-dev

# Add .bashrc
RUN touch /root/.bashrc \
    && echo 'export PS1="\w \\$ "' >> /root/.bashrc

WORKDIR /var/www/html
