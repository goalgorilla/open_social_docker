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


ADD mailcatcher-msmtp.conf /etc/msmtprc

RUN echo 'sendmail_path = "/usr/bin/msmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

ADD php.ini /usr/local/etc/php/php.ini

# Install extensions
RUN docker-php-ext-install zip bcmath exif sockets soap

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

# GMP library.
RUN apt-get install -y libgmp-dev
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/
RUN docker-php-ext-configure gmp
RUN docker-php-ext-install gmp

# simplesamlphp/simplesamlphp 2.1.0 requires ext-intl.
RUN apt-get install -y libicu-dev g++
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl

# Install composer dependencies.
RUN composer install --prefer-dist --no-interaction

# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /root/.composer/vendor/bin/behat /usr/local/bin/behat
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

# Drush 12 removes the need for the launcher and uses composer from vendor binary.
ENV PATH="$PATH:/var/www/vendor/bin:/usr/local/bin"

### CI SPECIFIC - END ###

RUN php -r "opcache_reset();"
