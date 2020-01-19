# 如何灵活使用 Hyperf dependencies 配置

[仓库地址](https://github.com/Dracovish/how-to-use-dependencies)

## 替换某个类的实现

让我们实现一个十分简单的 Service，代码如下

```php
<?php

namespace App\Service;

class DemoService
{
    public function say(): string
    {
        return 'I am in ' . static::class;
    }
}

```

然后控制器中调用，并返回数据

```
public function say()
{
    return $this->response->success(
        $this->container->get(DemoService::class)->say()
    );
}
```

访问接口，并查看结果

```
$ curl http://127.0.0.1:9501/index/say
{"code":0,"data":"I am in App\\Service\\DemoService"}
```

接下来我们重新写一个 Demo2Service

```php
<?php

namespace App\Service;

class Demo2Service
{
    public function say(): string
    {
        return 'I am not in ' . DemoService::class;
    }
}

```

然后修改 `dependencies.php` 配置。

```
<?php

use App\Service;

return [
    Service\DemoService::class => Service\Demo2Service::class,
];

```

访问接口，并查看结果

```
$ curl http://127.0.0.1:9501/index/say
{"code":0,"data":"I am not in App\\Service\\DemoService"}
```

可见 `DemoService` 会被直接替换成 `Demo2Service`。

## 活用 Factory

有时候我们需要使用多个 `Middleware`，虽然逻辑大致一样，但可能还是有一部分差别，这个时候通过上述方式，就显得有些单薄了，毕竟我需要两个都要。

让我们写一个简单的 `AuthMiddleware` 和 `UserAuth`。

```php
<?php

namespace App\Middleware;

use App\Service\UserAuth;
use Psr\Container\ContainerInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

class AuthMiddleware implements MiddlewareInterface
{
    /**
     * @var ContainerInterface
     */
    protected $container;

    /**
     * @var string
     */
    protected $pool;

    public function __construct(ContainerInterface $container, string $pool)
    {
        $this->container = $container;
        $this->pool = $pool;
    }

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        // TODO: 根据 pool 查询不通的 Redis 等存储引擎 并验证权限

        // 将对应的权限放到 UserAuth 中，这里模式传入一个 object，实际可以传入 Model 等。
        UserAuth::instance()->load((object) [
            'pool' => $this->pool,
        ]);

        return $handler->handle($request);
    }
}

```

```php
<?php

namespace App\Service;

use Hyperf\Utils\Traits\StaticInstance;

class UserAuth
{
    use StaticInstance;

    protected $user;

    public function load(object $user)
    {
        $this->user = $user;
    }
}

```

这个时候，如果存在两个 server，如果只有一份 `AuthMiddleware`，显然是无法满足的。比如以下配置

```php
<?php

use Hyperf\Server\Server;
use Hyperf\Server\SwooleEvent;

return [
    'mode' => SWOOLE_BASE,
    'servers' => [
        [
            'name' => 'http',
            'type' => Server::SERVER_HTTP,
            'host' => '0.0.0.0',
            'port' => 9501,
            'sock_type' => SWOOLE_SOCK_TCP,
            'callbacks' => [
                SwooleEvent::ON_REQUEST => [Hyperf\HttpServer\Server::class, 'onRequest'],
            ],
        ],
        [
            'name' => 'admin',
            'type' => Server::SERVER_HTTP,
            'host' => '0.0.0.0',
            'port' => 9502,
            'sock_type' => SWOOLE_SOCK_TCP,
            'callbacks' => [
                SwooleEvent::ON_REQUEST => ['AdminServer', 'onRequest'],
            ],
        ],
    ],
    'settings' => [
        'enable_coroutine' => true,
        'worker_num' => 4,
        'pid_file' => BASE_PATH . '/runtime/hyperf.pid',
        'open_tcp_nodelay' => true,
        'max_coroutine' => 100000,
        'open_http2_protocol' => true,
        'max_request' => 100000,
        'socket_buffer_size' => 2 * 1024 * 1024,
    ],
    'callbacks' => [
        SwooleEvent::ON_BEFORE_START => [Hyperf\Framework\Bootstrap\ServerStartCallback::class, 'beforeStart'],
        SwooleEvent::ON_WORKER_START => [Hyperf\Framework\Bootstrap\WorkerStartCallback::class, 'onWorkerStart'],
        SwooleEvent::ON_PIPE_MESSAGE => [Hyperf\Framework\Bootstrap\PipeMessageCallback::class, 'onPipeMessage'],
    ],
];
```

这个时候，我们使用 Factory 模式来很方便的将一份 AuthMiddleware 变成两份。

让我们创建两个 `Factory`。

```php
namespace App\Middleware\Factory;

use App\Middleware\AuthMiddleware;
use Psr\Container\ContainerInterface;

class AuthMiddlewareFactory
{
    public function __invoke(ContainerInterface $container)
    {
        return new AuthMiddleware($container, 'user');
    }
}

class AdminAuthMiddlewareFactory
{
    public function __invoke(ContainerInterface $container)
    {
        return new AuthMiddleware($container, 'admin');
    }
}
```

然后配置 dependencies.php 配置

```
<?php

use App\Middleware;
use App\Service;

return [
    // Hyperf\Contract\StdoutLoggerInterface::class => App\Kernel\Log\LoggerFactory::class,
    Service\DemoService::class => Service\Demo2Service::class,
    'AdminServer' => Hyperf\HttpServer\Server::class,
    'UserAuthMiddleware' => Middleware\Factory\AuthMiddlewareFactory::class,
    'AdminUserAuthMiddleware' => Middleware\Factory\AdminAuthMiddlewareFactory::class,
];

```

然后修改 `middlewares.php` 配置

```php
<?php

return [
    'http' => [
        'UserAuthMiddleware',
    ],
    'admin' => [
        'AdminUserAuthMiddleware',
    ],
];

```

接下来修改我们的接口。

```
public function pool()
{
    $user = UserAuth::instance()->getUser();

    return $this->response->success($user->pool);
}
```

测试

```
$ curl http://127.0.0.1:9501/index/pool
{"code":0,"data":"user"}

$ curl http://127.0.0.1:9502/index/pool
{"code":0,"data":"admin"}
```

当然，如果觉得写两个 Factory 比较繁琐，也可以使用更加方便的匿名函数

修改我们的 dependencies.php 配置如下

```php
<?php

use App\Middleware;
use App\Service;

return [
    // Hyperf\Contract\StdoutLoggerInterface::class => App\Kernel\Log\LoggerFactory::class,
    Service\DemoService::class => Service\Demo2Service::class,
    'AdminServer' => Hyperf\HttpServer\Server::class,
    // 'UserAuthMiddleware' => Middleware\Factory\AuthMiddlewareFactory::class,
    // 'AdminUserAuthMiddleware' => Middleware\Factory\AdminAuthMiddlewareFactory::class,
    'UserAuthMiddleware' => function () {
        return make(Middleware\AuthMiddleware::class, ['pool' => 'user']);
    },
    'AdminUserAuthMiddleware' => function () {
        return make(Middleware\AuthMiddleware::class, ['pool' => 'admin']);
    },
];

```

## 高级用法

接下来我们通过以上方式，修改一下框架里的类，这样可以在不修改源码的情况下，进行某些类的替换

比如，让我们修改一下 404 的返回。

```php
<?php

namespace App\Kernel\Http;

use Hyperf\HttpMessage\Stream\SwooleStream;
use Hyperf\HttpServer;
use Psr\Http\Message\ServerRequestInterface;

class CoreMiddleware extends HttpServer\CoreMiddleware
{
    protected function handleNotFound(ServerRequestInterface $request)
    {
        return $this->response()->withStatus(404)->withBody(new SwooleStream('Not Found.'));
    }
}

```

首先，在不替换的情况下，让我们访问一个不存在的路由

```
$ curl http://127.0.0.1:9501/index/not-found -i
HTTP/1.1 404 Not Found
Server: Hyperf
Connection: keep-alive
Content-Type: text/html
Date: Sun, 19 Jan 2020 06:53:36 GMT
Content-Length: 0
```

接下来我们修改 `dependencies.php` 配置

```php
<?php

use App\Kernel\Http;
use App\Middleware;
use App\Service;

return [
    // Hyperf\Contract\StdoutLoggerInterface::class => App\Kernel\Log\LoggerFactory::class,
    Service\DemoService::class => Service\Demo2Service::class,
    'AdminServer' => Hyperf\HttpServer\Server::class,
    // 'UserAuthMiddleware' => Middleware\Factory\AuthMiddlewareFactory::class,
    // 'AdminUserAuthMiddleware' => Middleware\Factory\AdminAuthMiddlewareFactory::class,
    'UserAuthMiddleware' => function () {
        return make(Middleware\AuthMiddleware::class, ['pool' => 'user']);
    },
    'AdminUserAuthMiddleware' => function () {
        return make(Middleware\AuthMiddleware::class, ['pool' => 'admin']);
    },
    Hyperf\HttpServer\CoreMiddleware::class => Http\CoreMiddleware::class,
];

```

然后再让我们访问试一下

```
$ curl http://127.0.0.1:9501/index/not-found -i
HTTP/1.1 404 Not Found
Server: Hyperf
Connection: keep-alive
Content-Type: text/html
Date: Sun, 19 Jan 2020 06:54:19 GMT
Content-Length: 10

Not Found.
```

可以看到，我们已经成功替换了对应的 `CoreMiddleware`。

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.4+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。
