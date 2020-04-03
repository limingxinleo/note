# 如何减少 Hyperf 框架的扫描时间

## 原因

`Hyperf` 框架为了防止用户更新组件后，代理缓存没有更新导致启动报错。增加了以下钩子。

```json
{
    "scripts": {
        "post-autoload-dump": [
            "init-proxy.sh"
        ]
    }
}
```

而 `init-proxy.sh` 脚本，会执行 ` php bin/hyperf.php di:init-proxy` 命令清理代理缓存，并重新生成。

```
$ composer init-proxy                            
> init-proxy.sh
../../
Runtime cleared
Scanning app ...
Scan app completed, took 195.76692581177 milliseconds.
Scanning vendor ...
Scan vendor completed, took 510.0839138031 milliseconds.
This command does not clear the runtime cache, If you want to delete them, use `vendor/bin/init-proxy.sh` instead.
Proxy class create success.
Finish!
```

上述演示中，我们很清楚的可以看到花费的时间，现在不足 `1s` 其实还可以接受。但如果您的模型非常多，这个时间可能会是无法忍受的一个点。比如以下情况。

```
$ composer init-proxy
> init-proxy.sh
../../
Runtime cleared
Scanning app ...
Scan app completed, took 3063.5998249054 milliseconds.
Scanning vendor ...
Scan vendor completed, took 490.39006233215 milliseconds.
This command does not clear the runtime cache, If you want to delete them, use `vendor/bin/init-proxy.sh` instead.
Proxy class create success.
Finish!
```

## 解决办法

所以，我们可以主动修改 `Hyperf` 框架的扫描目录，排除掉模型目录。让我们写一段逻辑，修改 `annotations.php`。

```php
<?php

declare(strict_types=1);

use Symfony\Component\Finder\Finder;

return [
    'scan' => [
        'paths' => value(function () {
            $paths = [];
            $dirs = Finder::create()->in(BASE_PATH . '/app')
                ->depth('< 1')
                ->exclude(['Model']) // 此处按照实际情况进行修改
                ->directories();
            /** @var SplFileInfo $dir */
            foreach ($dirs as $dir) {
                $paths[] = $dir->getRealPath();
            }
            return $paths;
        }),
        'ignore_annotations' => [
            'mixin',
        ],
    ],
];

```

当我们再执行命令时，就会发现时间被大大缩短。

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.4+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。