# Default Dockerfile
#
# @link     https://www.hyperf.io
# @document https://doc.hyperf.io
# @contact  group@hyperf.io
# @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE

FROM hyperf/hyperf:7.2-alpine-v3.9-cli
LABEL maintainer="Hyperf Developers <group@hyperf.io>" version="1.0" license="MIT"

##
# ---------- env settings ----------
##
# --build-arg timezone=Asia/Shanghai
ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"}

# update
RUN set -ex \
    && apk update \
    && apk add --no-cache php7-fpm php7-pcntl nginx \
    # install composer
    && cd /tmp \
    && wget https://mirrors.aliyun.com/composer/composer.phar \
    && chmod u+x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    # show php version and extensions
    && php -v \
    && php -m \
    && php --ri swoole \
    #  ---------- some config ----------
    && cd /etc/php7 \
    # - config PHP
    && { \
        echo "upload_max_filesize=100M"; \
        echo "post_max_size=108M"; \
        echo "memory_limit=1024M"; \
        echo "date.timezone=${TIMEZONE}"; \
    } | tee conf.d/99-overrides.ini \
    # - config timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    # - config PHP-FPM
    && cd /etc/php7 \
    # && echo "pid = /var/run/php-fpm.pid" >> php-fpm.d/www.conf \
    && sed -i "s/user = nobody/user = nginx/g" php-fpm.d/www.conf \
    && sed -i "s/group = nobody/group = nginx/g" php-fpm.d/www.conf \
    # - config site
    && mkdir /run/nginx \
    && mkdir /opt/www \
    && chown -R nginx:nginx /opt/www \
    && { \
        echo "#!/bin/sh"; \
        echo "nginx -g 'daemon on;'"; \
        echo "php-fpm7 -F"; \
    } | tee /run.sh \
    && chmod 755 /run.sh \
    # ---------- clear works ----------
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

WORKDIR /opt/www

# Composer Cache
# COPY ./composer.* /opt/www/
# RUN composer install --no-dev --no-scripts

COPY . /opt/www
RUN cp nginx.conf /etc/nginx/conf.d/nginx.conf \
    && composer install --no-dev -o

EXPOSE 9501

ENTRYPOINT ["/run.sh"]