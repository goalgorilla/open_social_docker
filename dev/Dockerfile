FROM goalgorilla/open_social_docker:latest-drupal95
MAINTAINER devel@goalgorilla.com

### DEV SPECIFIC - START ###

ADD php.ini /usr/local/etc/php/php.ini

# Xdebug.
RUN pecl install xdebug-3.1.1 && \
    docker-php-ext-enable xdebug && \
    sed -i '1 a xdebug.client_port=9003' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.mode=debug' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.discover_client_host=true' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.client_host=host.docker.internal' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.idekey=PHPSTORMi' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

### DEV SPECIFIC - END ###

RUN php -r "opcache_reset();"
