FROM drupal:11.3.3-php8.4
LABEL org.opencontainers.image.authors="devel@goalgorilla.com"

# Install packages.
RUN apt-get update && apt-get install -y \
  zlib1g-dev \
  libssl-dev \
  libxml2-dev \
  mariadb-client \
  curl \
  wget \
  git \
  msmtp \
  libzip-dev \
  nano \
  7zip \
  vim && \
  apt-get clean

# Disable client-side TLS requirement for the mariadb-client tools.
# Recent mariadb-client (11.8.x) defaults to --ssl=on at the binary level. Dev
# compose stacks typically run MariaDB without TLS, which breaks drush si and
# mariadb-dump. A /etc/mysql/conf.d override is not sufficient because Drush
# invokes `mariadb --defaults-file=...`, which bypasses the default config
# search path. Wrap the binaries to inject --skip-ssl regardless of caller.
RUN mv /usr/bin/mariadb /usr/bin/mariadb.real \
 && mv /usr/bin/mariadb-dump /usr/bin/mariadb-dump.real \
 && printf '#!/bin/sh\nexec /usr/bin/mariadb.real "$@" --skip-ssl\n' > /usr/bin/mariadb \
 && printf '#!/bin/sh\nexec /usr/bin/mariadb-dump.real "$@" --skip-ssl\n' > /usr/bin/mariadb-dump \
 && chmod +x /usr/bin/mariadb /usr/bin/mariadb-dump

ADD mailcatcher-msmtp.conf /etc/msmtprc

RUN echo 'sendmail_path = "/usr/bin/msmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

ADD php.ini /usr/local/etc/php/php.ini

# Install extensions
RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions
RUN install-php-extensions zip bcmath exif sockets soap gmp intl redis rdkafka

# Install Composer.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    EXPECTED=$(php -r "echo trim(file_get_contents('https://composer.github.io/installer.sig'));") && \
    ACTUAL=$(php -r "echo hash_file('sha384', 'composer-setup.php');") && \
    [ "$EXPECTED" = "$ACTUAL" ] || { echo 'Installer corrupt'; exit 1; } && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');"


# Install Open Social via composer.
RUN rm -f /var/www/composer.lock
RUN rm -rf /root/.composer

ADD composer.json /var/www/composer.json
WORKDIR /var/www/
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --prefer-dist --no-interaction --no-dev

WORKDIR /var/www/html/
RUN chown -R www-data:www-data *

RUN php -r 'opcache_reset();'

# Fix shell.
RUN echo "export TERM=xterm" >> ~/.bashrc

# Specify the work directory.
WORKDIR /var/www/

ADD php.ini /usr/local/etc/php/php.ini

### CI SPECIFIC - START ###

# Install composer dependencies.
RUN composer install --prefer-dist --no-interaction

# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /root/.composer/vendor/bin/behat /usr/local/bin/behat
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

# Drush 12 removes the need for the launcher and uses composer from vendor binary.
ENV PATH="$PATH:/var/www/vendor/bin:/usr/local/bin"

### CI SPECIFIC - END ###

### DEV SPECIFIC - START ###

# Xdebug (3.4.x for PHP 8.4).
RUN pecl install xdebug-3.4.2 && \
    docker-php-ext-enable xdebug && \
    sed -i '1 a xdebug.client_port=9003' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.mode=debug' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.discover_client_host=true' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.client_host=host.docker.internal' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.idekey=PHPSTORM' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

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
