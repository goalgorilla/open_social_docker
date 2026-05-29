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
RUN install-php-extensions zip bcmath exif sockets soap gmp intl rdkafka

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

RUN php -r "opcache_reset();"
