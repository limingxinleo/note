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

FROM swoft/alphp:base
LABEL maintainer="limx <limingxin@swoft.org>" version="1.0"

##
# ---------- env settings ----------
##
ENV SWOOLE_VERSION=4.2.10 \
    DOCKER_ENVIRONMENT=true \
    #  install and remove building packages
    PHPIZE_DEPS="autoconf dpkg-dev dpkg file g++ gcc libc-dev make php7-dev php7-pear pkgconf re2c pcre-dev zlib-dev"

# update
RUN set -ex \
    && apk update \
    # for swoole extension libaio linux-headers
    && apk add --no-cache libstdc++ openssl php7-xml php7-xmlreader php7-xmlwriter php7-pcntl git bash \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS libaio-dev openssl-dev \

    # download
    && cd /tmp \
    && curl -SL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" -o swoole.tar.gz \
    && ls -alh \

    # php extension:swoole
    && cd /tmp \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-mysqlnd --enable-openssl \
        && make -s -j$(nproc) && make install \
    ) \
    && echo "extension=swoole.so" > /etc/php7/conf.d/swoole.ini \

    # install composer
    && cd /tmp \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer self-update --clean-backups \

    # clear
    && php -v \
    && php -m \
    # ---------- clear works ----------
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

COPY . /opt/www

WORKDIR /opt/www

RUN composer install --no-dev \
    && composer dump-autoload -o \
    && php /opt/www/bin/swoft app:init

EXPOSE 8080 8099

ENTRYPOINT ["php", "/opt/www/bin/swoft", "start"]
