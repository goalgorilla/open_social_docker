FROM drupal:9.5-php8.1
MAINTAINER devel@goalgorilla.com

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
  p7zip-full \
  vim && \
  apt-get clean


ADD mailcatcher-msmtp.conf /etc/msmtprc

RUN echo 'sendmail_path = "/usr/bin/msmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

ADD php.ini /usr/local/etc/php/php.ini

# Install extensions
RUN docker-php-ext-install zip bcmath exif sockets soap

# Install Composer.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    php composer-setup.php \
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

# Install Drush launcher.
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.10.1/drush.phar && \
	chmod +x drush.phar && \
	mv drush.phar /usr/local/bin/drush

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

# Install composer dependencies.
RUN composer install --prefer-dist --no-interaction

# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /root/.composer/vendor/bin/behat /usr/local/bin/behat
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/local/bin/phpunit

### CI SPECIFIC - END ###

RUN php -r "opcache_reset();"
