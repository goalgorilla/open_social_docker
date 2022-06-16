FROM drupal:9.3.16-php8.0
MAINTAINER devel@goalgorilla.com

# Install packages.
RUN apt-get update && apt-get install -y \
  zlib1g-dev \
  libssl-dev \
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
RUN docker-php-ext-install zip bcmath exif sockets

# Install Composer.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php && \
    mv composer.phar /usr/local/bin/composer && \
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
