# Hyperf2.0新功能早知道

在使用 `Hyperf1.1` 的小伙伴们，通常都会碰到这么一个问题，那就是协程上下文数据拷贝的问题。

比如我实现了一个 `Listener`，在监听 `SQL` 的同时，会把当前请求的路由数据记录下来。当出现慢查的时候，就可以精确定位到是哪个路由。

但当你以以下方式执行 `SQL` 时，可能就会出现这个错误 `TypeError:Return value of Hyperf\HttpServer\Request::getRequest() must implement interface Psr\Http\Message\ServerRequestInterface, null returned`

```php
<?php

go(function(){
    Db::select("SELECT * FROM users;");
})
```

当然，你可以自己实现 `go` 方法，然后在 `composer` 加载之前提前加载这个文件。例如

```
// 包含 go 方法的实现
require BASE_PATH . '/config/bootstrap.php';

require BASE_PATH . '/vendor/autoload.php';
```

但框架中直接使用 `Coroutine::create` 来创建协程就没有办法了，比如 `Parallel` 和 `Concurrent` 等等

## ClassMap 功能

而在 `Hyperf2.0` 版本中，框架实现了基于 `composer class map` 的替换功能，你可以自己实现 `Hyperf\Utils\Coroutine`，而框架会自动帮你替换掉原来的 `Hyperf\Utils\Coroutine`。

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
namespace Hyperf\Utils;

use App\Kernel\Context\Coroutine as BCoroutine;
use Swoole\Coroutine as SwooleCoroutine;

/**
 * @method static void defer(callable $callable)
 */
class Coroutine
{
    public static function __callStatic($name, $arguments)
    {
        if (! method_exists(SwooleCoroutine::class, $name)) {
            throw new \BadMethodCallException(sprintf('Call to undefined method %s.', $name));
        }
        return SwooleCoroutine::$name(...$arguments);
    }

    /**
     * Returns the current coroutine ID.
     * Returns -1 when running in non-coroutine context.
     */
    public static function id(): int
    {
        return SwooleCoroutine::getCid();
    }

    /**
     * Returns the parent coroutine ID.
     * Returns -1 when running in the top level coroutine.
     * Returns null when running in non-coroutine context.
     *
     * @see https://github.com/swoole/swoole-src/pull/2669/files#diff-3bdf726b0ac53be7e274b60d59e6ec80R940
     */
    public static function parentId(): ?int
    {
        $cid = SwooleCoroutine::getPcid();
        if ($cid === false) {
            return null;
        }

        return $cid;
    }

    /**
     * @return int Returns the coroutine ID of the coroutine just created.
     *             Returns -1 when coroutine create failed.
     */
    public static function create(callable $callable): int
    {
        return di()->get(BCoroutine::class)->create($callable);
    }

    public static function inCoroutine(): bool
    {
        return Coroutine::id() > 0;
    }
}

```

`App\Kernel\Context\Coroutine` 是实现了协程上下文拷贝功能的类。

## 测试

让我们写一段代码，进行测试。

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
namespace App\Controller;

class IndexController extends Controller
{
    public function index()
    {
        $user = $this->request->input('user', 'Hyperf');
        $method = $this->request->getMethod();
        go(function () {
            var_dump($this->request->input('user'));
        });
        return $this->response->success([
            'user' => $user,
            'method' => $method,
            'message' => 'Hello Hyperf.',
        ]);
    }
}

```

当我们不使用 `ClassMap` 功能时，调用接口，会抛出以下错误。

```
[WARNING] TypeError:Return value of Hyperf\HttpServer\Request::getRequest() must implement interface Psr\Http\Message\ServerRequestInterface, null returned(0) in /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/http-server/src/Request.php:620
Stack trace:
#0 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/http-server/src/Request.php(579): Hyperf\HttpServer\Request->getRequest()
#1 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/utils/src/Functions.php(268): Hyperf\HttpServer\Request->Hyperf\HttpServer\{closure}()
#2 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/http-server/src/Request.php(593): call(Object(Closure))
#3 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/http-server/src/Request.php(587): Hyperf\HttpServer\Request->storeParsedData(Object(Closure))
#4 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/http-server/src/Request.php(97): Hyperf\HttpServer\Request->getInputData()
#5 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/app/Controller/IndexController.php(21): Hyperf\HttpServer\Request->input('user')
#6 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/utils/src/Functions.php(268): App\Controller\IndexController->App\Controller\{closure}()
#7 /Users/limx/Applications/GitHub/hyperf/biz-skeleton/vendor/hyperf/utils/src/Coroutine.php(67): call(Object(Closure))
#8 {main}
```

当我们配置了 `ClassMap` 后，结果就正常了。

```
$ curl http://127.0.0.1:9501/\?user\=Hyperf
{"code":0,"data":{"user":"Hyperf","method":"GET","message":"Hello Hyperf."}}

string(6) "Hyperf"
```

可见 `App\Kernel\Context\Coroutine` 已被正确替换。

> 大家可以考虑一下，哪些场景，通过这个办法可以轻松的解决呢？

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.4+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。