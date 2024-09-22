FROM php:8.1-apache

MAINTAINER Konrad Roziewski <kroziewski@gmail.com>

WORKDIR /var/www/html
RUN DEBIAN_FRONTEND=noninteractive apt update && apt install -y pkg-config nfdump rrdtool librrd-dev git wget
RUN a2enmod rewrite deflate headers expires
RUN pecl install rrd
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo "extension=rrd.so" >> /usr/local/etc/php/conf.d/rrd.ini
RUN sed -e '/<Directory \/var\/www\/>/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' -i /etc/apache2/apache2.conf

RUN git clone --depth 1 --branch v0.3.1 https://github.com/mbolli/nfsen-ng.git .
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet
RUN php composer.phar install --no-dev

COPY settings.php backend/settings/settings.tmpl
COPY entrypoint.sh /tmp/

RUN chown -R www-data:www-data .
RUN chmod +x backend/cli.php /tmp/entrypoint.sh

ENV PROFILES_DATA_PATH  /var/nfdump/profiles-data/
ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2

VOLUME [ "/var/nfdump/profiles-data" ]

EXPOSE 80

ENTRYPOINT [ "/tmp/entrypoint.sh" ]
