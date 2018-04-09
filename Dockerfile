FROM drupal:8.4
MAINTAINER devel@goalgorilla.com

# Install packages.
RUN apt-get update && apt-get install -y \
  zlib1g-dev \
  mysql-client \
  git \
  ssmtp \
  nano \
  vim && \
  apt-get clean

ADD mailcatcher-ssmtp.conf /etc/ssmtp/ssmtp.conf

RUN echo "hostname=goalgorilla.com" >> /etc/ssmtp/ssmtp.conf
RUN echo 'sendmail_path = "/usr/sbin/ssmtp -t"' > /usr/local/etc/php/conf.d/mail.ini

ADD php.ini /usr/local/etc/php/php.ini

# Install extensions
RUN docker-php-ext-install zip
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Install Open Social via composer.
RUN rm -f /var/www/composer.lock
RUN rm -rf /root/.composer

ADD composer.json /var/www/composer.json
WORKDIR /var/www/
RUN composer install --prefer-dist --no-interaction --no-dev

WORKDIR /var/www/html/
RUN chown -R www-data:www-data *

# Unfortunately, adding the composer vendor dir to the PATH doesn't seem to work. So:
RUN ln -s /var/www/vendor/bin/drush /usr/local/bin/drush

RUN php -r 'opcache_reset();'

# Fix shell.
RUN echo "export TERM=xterm" >> ~/.bashrc
