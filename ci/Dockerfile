FROM goalgorilla/open_social_docker:latest-experimental
MAINTAINER devel@goalgorilla.com

### CI SPECIFIC - START ###
ADD php.ini /usr/local/etc/php/php.ini
### CI SPECIFIC - END ###

RUN php -r "opcache_reset();"
