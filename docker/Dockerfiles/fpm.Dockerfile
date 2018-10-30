# @description php 7.1 image base on the alpine 3.7 镜像更小，构建完成只有46M
#                       some information
# ------------------------------------------------------------------------------------
# @link https://hub.docker.com/_/alpine/      alpine image
# @link https://hub.docker.com/_/php/         php image
# @link https://github.com/docker-library/php php dockerfiles
# ------------------------------------------------------------------------------------
# @build-example docker build . -f Dockerfile -t swoft/swoft-project:v1.0
# @run-example docker run --rm -d -p 8080:8080 --name swoft-project swoft/swoft-project:1.0
# @run-example docker run --rm -d -p 8080:8080 --name swoft-project --env-file .env registry.cn-shanghai.aliyuncs.com/limingxinleo/swoft-project:latest
#

FROM swoft/alphp:base
LABEL maintainer="limx <limingxin@swoft.org>" version="1.0"

##
# ---------- env settings ----------
##
ENV HIREDIS_VERSION=0.13.3 \
    SWOOLE_VERSION=4.2.5 \
    MONGO_VERSION=1.5.2 \
    CPHALCON_VERSION=3.4.1 \
    #  install and remove building packages
    PHPIZE_DEPS="autoconf dpkg-dev dpkg file g++ gcc libc-dev make php7-dev php7-pear pkgconf re2c pcre-dev zlib-dev"

##
# install php extensions
##
RUN set -ex \
        && cd /tmp \
        && curl -SL "https://github.com/redis/hiredis/archive/v${HIREDIS_VERSION}.tar.gz" -o hiredis.tar.gz \
        && curl -SL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz \
        && curl -SL "http://pecl.php.net/get/mongodb-${MONGO_VERSION}.tgz" -o mongodb.tgz \
        && curl -SL "https://github.com/phalcon/cphalcon/archive/v${CPHALCON_VERSION}.zip" -o cphalcon.zip \
        && ls -alh \
        && apk update \
        # for swoole extension libaio linux-headers
        && apk add --no-cache libstdc++ openssl php7-xml php7-pcntl git bash \
        && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS libaio-dev openssl-dev \
        # php extension: mongodb
        && pecl install mongodb.tgz \
        && echo "extension=mongodb.so" > /etc/php7/conf.d/mongodb.ini \
        # php extension: phalcon
        && cd /tmp \
        && unzip cphalcon.zip \
        && rm cphalcon.zip \
        && ( \
            cd cphalcon-${CPHALCON_VERSION}/build \
            && ./install \
            && echo "extension=phalcon.so" > /etc/php7/conf.d/phalcon.ini \
        ) \
        && rm -r cphalcon-${CPHALCON_VERSION} \
        # hiredis - redis C client, provide async operate support for Swoole
        && cd /tmp \
        && tar -zxvf hiredis.tar.gz \
        && cd hiredis-${HIREDIS_VERSION} \
        && make -j && make install \
        # php extension: swoole
        && cd /tmp \
        && mkdir -p swoole \
        && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
        && rm swoole.tar.gz \
        && ( \
            cd swoole \
            && phpize \
            && ./configure --enable-async-redis --enable-mysqlnd --enable-openssl \
            && make -j$(nproc) && make install \
        ) \
        && rm -r swoole \
        && echo "extension=swoole.so" > /etc/php7/conf.d/swoole.ini \
        && php -v \
        # ---------- clear works ----------
        && apk del .build-deps \
        && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
        && echo -e "\033[42;37m Build Completed :).\033[0m\n"

##
# install nginx fpm
##
RUN set -ex \
        && apk add --no-cache php7-fpm php7-pcntl nginx \
        && apk del --purge *-dev \
        && rm -rf /var/cache/apk/* /tmp/* /usr/share/man /usr/share/php7 \
        && mkdir -p /opt/www \
        # - config nginx
        && mkdir /run/nginx \
        # - config PHP-FPM
        && cd /etc/php7 \
        # && echo "pid = /var/run/php-fpm.pid" >> php-fpm.d/www.conf \
        && sed -i "s/user = nobody/user = www-data/g" php-fpm.d/www.conf \
        && sed -i "s/group = nobody/group = www-data/g" php-fpm.d/www.conf \
        # - config site
        && chown -R www-data:www-data /opt/www \
        && { \
            echo "#!/bin/sh"; \
            echo "nginx -g 'daemon on;'"; \
            echo "php-fpm7 -F"; \
        } | tee /run.sh \
        && chmod 755 /run.sh \
        && echo -e "\033[42;37m Build Completed :).\033[0m\n"

# 安装composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups

COPY . /opt/www

# 复制Nginx配置
RUN cp /opt/www/nginx.conf /etc/nginx/conf.d/nginx.conf

WORKDIR /opt/www

RUN composer install --no-dev \
    && composer dump-autoload -o \
    && chown -R www-data:www-data *

EXPOSE 8080

ENTRYPOINT ["/run.sh"]