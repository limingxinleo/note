# Waiter for Hyperf

`Hyperf` 中 `Database` 连接池的设计，是在 `defer` 中释放连接到连接池，那么就会出现一种情况。

```
// 读取用户信息
$user = User::query()->find(1);

// 请求第三方接口
$client->request($user);

// 保存用户信息
$user->save();
```

以上场景，就会导致 `DB` 连接一直在当前协程的上下文中，虽然中间请求第三方接口，耗时了很久，但其他协程都无法拿到当前的 `DB` 连接。这就导致，连接池内的连接数会被迅速消耗，
一旦时间过长，其他请求可能就会出现连接耗尽的异常。

显而易见，我们只需要让读取用户信息的逻辑，跑在子协程中，然后配合 `Channel` 阻塞当前协程即可。

`v2.1` 里已经实现了这个方法，`v2.0` 中我们可以导入以下组件

```
composer require gemini/waiter
```

然后我们可以调用 `wait()` 方法，达成这个效果。

```
// 读取用户信息
$user = wait(function() {
    return User::query()->find(1);
});

// 请求第三方接口
$client->request($user);

// 保存用户信息
$user->save();
```

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.5+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。

