FROM goalgorilla/open_social_docker:latest-php8.1
MAINTAINER devel@goalgorilla.com

### CI SPECIFIC - START ###
### - Making changes here? Also apply in ../ci/Dockerfile ###

# Specify the work directory.
WORKDIR /var/www/

# Install composer dependencies.
RUN composer install --prefer-dist --no-interaction

# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /root/.composer/vendor/bin/behat /usr/local/bin/behat
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

### CI SPECIFIC - END ###

### DEV SPECIFIC - START ###

ADD php.ini /usr/local/etc/php/php.ini

# GMP library.
RUN apt-get install -y libgmp-dev
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN docker-php-ext-configure gmp
RUN docker-php-ext-install gmp

# Xdebug.
RUN pecl install xdebug-3.1.1 && \
    docker-php-ext-enable xdebug && \
    sed -i '1 a xdebug.client_port=9003' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.mode=debug' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.discover_client_host=true' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.client_host=host.docker.internal' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.idekey=PHPSTORMi' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Blackfire
# @todo Fix PHP 8 based blackfire installation
#RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
#    && architecture=$(uname -m) \
#    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/$architecture/$version \
#    && mkdir -p /tmp/blackfire \
#    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
#    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
#    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8307\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
#    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

RUN php -r "opcache_reset();"

# @todo Remove these steps as it is not required for latest Docker desktop.
# Contains the Mac hack to get the permissions to work for development.
# Set user 1000 and group staff to www-data, enables write permission.
# https://github.com/boot2docker/boot2docker/issues/581#issuecomment-114804894
#RUN usermod -u 1000 www-data
#RUN usermod -G staff www-data

### DEV SPECIFIC - END ###

# Redis.
RUN pecl install redis \
 && docker-php-ext-enable redis
