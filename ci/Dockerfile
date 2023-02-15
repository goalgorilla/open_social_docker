FROM goalgorilla/open_social_docker:latest-drupal95
MAINTAINER devel@goalgorilla.com

### CI SPECIFIC - START ###
ADD php.ini /usr/local/etc/php/php.ini
### CI SPECIFIC - END ###

RUN php -r "opcache_reset();"
