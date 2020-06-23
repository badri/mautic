FROM lakshminp/php-base:7.2 as composer-base

# work dir change
COPY composer.json composer.lock /var/www/symfony/

WORKDIR /var/www/symfony

RUN COMPOSER_CACHE_DIR=/var/www/symfony/.cache composer install \
    --no-interaction \
    --no-dev \
    --no-autoloader

FROM composer-base as composer-autoload

# copy from . to workdir
COPY . /var/www/symfony

RUN composer dump-autoload \
    --no-interaction \
    --no-dev \
    --classmap-authoritative \
    --quiet

FROM lakshminp/php-base:7.2 as production

COPY . /var/www/symfony

RUN useradd -u 1001 -r -g 0 -d /app -s /bin/bash -c "Default Application User" default \
    && chown -R 1001:0 /var/www/symfony && chmod -R g+rwX /var/www/symfony


RUN mkdir /cache && chown -R 1001:0 /cache && chmod -R g+rwX /cache
RUN mkdir /logs && chown -R 1001:0 /logs && chmod -R g+rwX /logs


COPY --from=composer-base /var/www/symfony/vendor /var/www/symfony/vendor
COPY --from=composer-autoload /var/www/symfony/vendor/autoload.php /var/www/symfony/vendor/
COPY --from=composer-autoload /var/www/symfony/vendor/composer /var/www/symfony/vendor/composer

RUN mkdir -p /var/www/symfony/translations

WORKDIR /var/www/symfony

USER 1001
