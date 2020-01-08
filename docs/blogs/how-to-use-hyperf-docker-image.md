# 如何使用 Hyperf Docker 镜像

如果你用的是 `Hyperf` 框架，这篇文章你大可以跳过，因为官方提供的骨架包，已经集成了相应的 `Dockerfile` 和 `Gitlab CI/CD` 配置。

今天，我们主要来说一下，非 `Hyperf` 框架，如何使用 `Hyperf` 的官方镜像。

[仓库地址](https://github.com/Dracovish/imi-in-hyperf-docker)

## 安装一个项目

```
composer create-project imiphp/project-http imi-in-hyperf-docker
```

1. 首先，我们添加一个 `.php-cs` 文件进来，方便我们格式化代码

这里我们直接使用 `Hyperf` 的格式化文件即可。

```
<?php

$header = <<<'EOF'
This file is part of Hyperf.

@link     https://www.hyperf.io
@document https://doc.hyperf.io
@contact  group@hyperf.io
@license  https://github.com/hyperf/hyperf/blob/master/LICENSE
EOF;

return PhpCsFixer\Config::create()
    ->setRiskyAllowed(true)
    ->setRules([
        '@PSR2' => true,
        '@Symfony' => true,
        '@DoctrineAnnotation' => true,
        '@PhpCsFixer' => true,
        'header_comment' => [
            'commentType' => 'PHPDoc',
            'header' => $header,
            'separate' => 'none',
            'location' => 'after_declare_strict',
        ],
        'array_syntax' => [
            'syntax' => 'short'
        ],
        'list_syntax' => [
            'syntax' => 'short'
        ],
        'concat_space' => [
            'spacing' => 'one'
        ],
        'blank_line_before_statement' => [
            'statements' => [
                'declare',
            ],
        ],
        'general_phpdoc_annotation_remove' => [
            'annotations' => [
                'author'
            ],
        ],
        'ordered_imports' => [
            'imports_order' => [
                'class', 'function', 'const',
            ],
            'sort_algorithm' => 'alpha',
        ],
        'single_line_comment_style' => [
            'comment_types' => [
            ],
        ],
        'yoda_style' => [
            'always_move_variable' => false,
            'equal' => false,
            'identical' => false,
        ],
        'phpdoc_align' => [
            'align' => 'left',
        ],
        'multiline_whitespace_before_semicolons' => [
            'strategy' => 'no_multi_line',
        ],
        'class_attributes_separation' => true,
        'combine_consecutive_unsets' => true,
        'declare_strict_types' => true,
        'linebreak_after_opening_tag' => true,
        'lowercase_constants' => true,
        'lowercase_static_reference' => true,
        'no_useless_else' => true,
        'no_unused_imports' => true,
        'not_operator_with_successor_space' => true,
        'not_operator_with_space' => false,
        'ordered_class_elements' => true,
        'php_unit_strict' => false,
        'phpdoc_separation' => false,
        'single_quote' => true,
        'standardize_not_equals' => true,
        'multiline_comment_opening_closing' => true,
    ])
    ->setFinder(
        PhpCsFixer\Finder::create()
            ->exclude('public')
            ->exclude('.runtime')
            ->exclude('vendor')
            ->in(__DIR__)
    )
    ->setUsingCache(false);
```

接下来，导入 `friendsofphp/php-cs-fixer` 包

```
composer require friendsofphp/php-cs-fixer --dev
```

然后添加 `script` 到我们的 `composer.json` 中

```
"cs-fix": "php-cs-fixer fix $1"
```

接下来执行 `composer cs-fix` 就可以很方便的格式化我们的代码。

2. 启动 Server

```
vendor/bin/imi server/start
```

测试

```
curl http://127.0.0.1:9501/
<p>2020-01-08 18:45:34</p>
```

## 编写 Dockerfile

`Hyperf` 框架需要重写 `go` 和 `defer` 方法，所以需要设置 `swoole.use_shortname = 'Off'`，而 `IMI` 等其他框架可能并没有这个要求，反而，框架内部可能用到了 `go` 和 `defer` 方法。所以我们的 `Dockerfile` 必须修改为开启状态。

我们以 `Hyperf` 项目默认的 `Dockerfile` 为基础，只需要增加 `"swoole.use_shortname = 'On'";` 到 `99_overrides.ini` 中，并修改启动命令即可。

```Dockerfile
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

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    APP_ENV=prod

# update
RUN set -ex \
    && apk update \
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
        echo "swoole.use_shortname = 'On'"; \
    } | tee conf.d/99_overrides.ini \
    # - config timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    # ---------- clear works ----------
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

WORKDIR /opt/www

# Composer Cache
# COPY ./composer.* /opt/www/
# RUN composer install --no-dev --no-scripts

COPY . /opt/www
RUN composer install --no-dev -o

EXPOSE 9501

ENTRYPOINT ["/opt/www/vendor/bin/imi", "server/start"]

```

## 打包并启动

```
docker build -t imi .
docker run -p 9501:9501 --name imi --rm -d imi
curl http://127.0.0.1:9501/
```

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.4+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。
