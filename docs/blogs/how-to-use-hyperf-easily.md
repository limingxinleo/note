# 使用 Hyperf 的小技巧

在这两年的开源过程中，接到过非常多奇奇怪怪的问题，总结起来，其实就是那几个小问题，接下来我借 [biz-skeleton](https://github.com/hyperf/biz-skeleton) 这个项目，
为大家简单说一下使用 Hyperf 过程中的小技巧。

## 简化容器单例读取方法

框架层级提供了一个方法，可以拿到整个容器实例。

```php
<?php
use Hyperf\Context\ApplicationContext;
use App\Service\UserService;

$container = ApplicationContext::getContainer();

$container->get(UserService::class);
```

这种方式使用起来会稍微有点不够方便，所以我们可以实现一个方法。

https://github.com/hyperf/biz-skeleton/blob/master/app/Kernel/Functions.php#L17

```php
<?php
use Hyperf\Context\ApplicationContext;

if (! function_exists('di')) {
    /**
     * Finds an entry of the container by its identifier and returns it.
     * @return mixed|\Psr\Container\ContainerInterface
     */
    function di(?string $id = null)
    {
        $container = ApplicationContext::getContainer();
        if ($id) {
            return $container->get($id);
        }

        return $container;
    }
}
```

当然，这个文件是需要通过 `Psr4` 规范加载进来的，所以我们需要修改对应的配置

https://github.com/hyperf/biz-skeleton/blob/master/composer.json#L62

```json
{
    "autoload": {
        "psr-4": {
            "App\\": "app/"
        },
        "files": [
            "app/Kernel/Functions.php"
        ]
    }
}

```

这样在使用的时候，我们就可以方便的使用以下代码进行方法调用。

```php
use App\Service\UserService;
use function di;

di()->get(UserService::class);
```

## 巧用协程上下文复制

Hyperf 框架默认是认为，每一个协程是独立存在的，所以不会在请求层级，对子协程进行约束，所以在实际使用时，可能存在这种情况。

比如在 `wait` `go` 或者 `parallel` 方法中，使用到了协程上下文。

例如以下代码

```php
<?php

declare(strict_types=1);

namespace App\Controller;

use Hyperf\Context\Context;

use function Hyperf\Coroutine\wait;

class IndexController extends Controller
{
    public function index()
    {
        $id = Context::getOrSet('id', uniqid());
        $id2 = wait(function () {
            return Context::getOrSet('id', uniqid());
        });

        var_dump($id, $id2);

        return $this->response->success('');
    }
}

```

当我们访问 `http://127.0.0.1:9501/` 时，就会看到输出的 id 并不相同。

所以，我们可以重写协程创建方法，默认处理这个问题。我们先创建一个支持复制上下文的 `Coroutine`

https://github.com/hyperf/biz-skeleton/blob/master/app/Kernel/Context/Coroutine.php

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */

namespace App\Kernel\Context;

use App\Kernel\Log\AppendRequestIdProcessor;
use Hyperf\Context\Context;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Engine\Coroutine as Co;
use Psr\Container\ContainerInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Log\LoggerInterface;
use Throwable;

class Coroutine
{
    protected LoggerInterface $logger;

    public function __construct(protected ContainerInterface $container)
    {
        $this->logger = $container->get(StdoutLoggerInterface::class);
    }

    /**
     * @return int Returns the coroutine ID of the coroutine just created.
     *             Returns -1 when coroutine create failed.
     */
    public function create(callable $callable): int
    {
        $id = Co::id();
        $coroutine = Co::create(function () use ($callable, $id) {
            try {
                // Shouldn't copy all contexts to avoid socket already been bound to another coroutine.
                Context::copy($id, [
                    AppendRequestIdProcessor::REQUEST_ID,
                    ServerRequestInterface::class,
                    // 按照上述测试逻辑，复制 id 数据到子协程
                    'id'
                ]);
                $callable();
            } catch (Throwable $throwable) {
                $this->logger->warning((string) $throwable);
            }
        });

        try {
            return $coroutine->getId();
        } catch (Throwable $throwable) {
            $this->logger->warning((string) $throwable);
            return -1;
        }
    }
}

```

然后重新实现 `Hyperf\Coroutine\Coroutine` 类

https://github.com/hyperf/biz-skeleton/blob/master/app/Kernel/ClassMap/Coroutine.php

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */

namespace Hyperf\Coroutine;

use App\Kernel\Context\Coroutine as Go;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Engine\Coroutine as Co;
use Hyperf\Engine\Exception\CoroutineDestroyedException;
use Hyperf\Engine\Exception\RunningInNonCoroutineException;
use Throwable;

class Coroutine
{
    /**
     * Returns the current coroutine ID.
     * Returns -1 when running in non-coroutine context.
     */
    public static function id(): int
    {
        return Co::id();
    }

    public static function defer(callable $callable): void
    {
        Co::defer(static function () use ($callable) {
            try {
                $callable();
            } catch (Throwable $exception) {
                di()->get(StdoutLoggerInterface::class)->error((string) $exception);
            }
        });
    }

    public static function sleep(float $seconds): void
    {
        usleep(intval($seconds * 1000 * 1000));
    }

    /**
     * Returns the parent coroutine ID.
     * Returns 0 when running in the top level coroutine.
     * @throws RunningInNonCoroutineException when running in non-coroutine context
     * @throws CoroutineDestroyedException when the coroutine has been destroyed
     */
    public static function parentId(?int $coroutineId = null): int
    {
        return Co::pid($coroutineId);
    }

    /**
     * @return int Returns the coroutine ID of the coroutine just created.
     *             Returns -1 when coroutine create failed.
     */
    public static function create(callable $callable): int
    {
        return di()->get(Go::class)->create($callable);
    }

    public static function inCoroutine(): bool
    {
        return Co::id() > 0;
    }

    public static function stats(): array
    {
        return Co::stats();
    }

    public static function exists(int $id): bool
    {
        return Co::exists($id);
    }
}

```

最后我们配置 `annotations.scan.class_map`

https://github.com/hyperf/biz-skeleton/blob/master/config/autoload/annotations.php#L21

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
return [
    'scan' => [
        'paths' => [
            BASE_PATH . '/app',
        ],
        'ignore_annotations' => [
            'mixin',
        ],
        'class_map' => [
            Hyperf\Coroutine\Coroutine::class => BASE_PATH . '/app/Kernel/ClassMap/Coroutine.php',
        ],
    ],
];

```

接下来重新进行测试，就发现我们输出的两个 id 是完全相同的了。

## 重写框架默认日志类

框架提供了一个非常简单的 `Stdout` 日志类，但实际在使用时，是万万无法满足我们实际需要的，这就需要通过配置 `dependencies.php` 做到轻松替换原实例的功能。

https://github.com/hyperf/biz-skeleton/blob/master/app/Kernel/Log/LoggerFactory.php

```php
<?php

declare(strict_types=1);

namespace App\Kernel\Log;

use Hyperf\Logger\LoggerFactory as HyperfLoggerFactory;
use Psr\Container\ContainerInterface;

class LoggerFactory
{
    public function __invoke(ContainerInterface $container)
    {
        return $container->get(HyperfLoggerFactory::class)->make();
    }
}

```

https://github.com/hyperf/biz-skeleton/blob/master/config/autoload/dependencies.php#L13

```php
<?php

declare(strict_types=1);

return [
    Hyperf\Contract\StdoutLoggerInterface::class => App\Kernel\Log\LoggerFactory::class,
];

```

接下来测试下，就能看到我们所有的默认日志输出，都被 `Monolog` 接管。

当然，有时候我们其实是想将一个请求里的日志，都关联起来，并且子协程也可以进行关联，我们通过组合 `协程复制` 和 `Monolog` 轻松的达成这个效果。

首先我们创建一个 `AppendRequestIdProcessor`

https://github.com/hyperf/biz-skeleton/blob/master/app/Kernel/Log/AppendRequestIdProcessor.php

```php
<?php

declare(strict_types=1);

namespace App\Kernel\Log;

use Hyperf\Context\Context;
use Hyperf\Coroutine\Coroutine;
use Monolog\LogRecord;
use Monolog\Processor\ProcessorInterface;

class AppendRequestIdProcessor implements ProcessorInterface
{
    public const REQUEST_ID = 'log.request.id';

    public function __invoke(array|LogRecord $record)
    {
        $record['extra']['request_id'] = Context::getOrSet(self::REQUEST_ID, uniqid());
        $record['extra']['coroutine_id'] = Coroutine::id();
        return $record;
    }
}

```

接下来修改我们的 `logger` 配置。

https://github.com/hyperf/biz-skeleton/blob/master/config/autoload/logger.php#L33

```php
<?php

declare(strict_types=1);

use App\Kernel\Log;

return [
    'default' => [
        'handler' => [
            'class' => Monolog\Handler\StreamHandler::class,
            'constructor' => [
                'stream' => BASE_PATH . '/runtime/logs/hyperf.log',
                'level' => Monolog\Logger::INFO,
            ],
        ],
        'formatter' => [
            'class' => Monolog\Formatter\LineFormatter::class,
            'constructor' => [
                'format' => null,
                'dateFormat' => 'Y-m-d H:i:s',
                'allowInlineLineBreaks' => true,
            ],
        ],
        'processors' => [
            [
                'class' => Log\AppendRequestIdProcessor::class,
            ],
        ],
    ],
];

```

接下来再重新测试，就可以看到我们每一条日志后面，都会有一条对应的 `request_id`。

但，子协程还是无法进行关联，所以我们只需要重写 `Coroutine` 类，将 `REQUEST_ID` 复制到子协程即可，此代码上述已经表现出来，可以翻上去查看。

## 使用协程风格服务

`Hyperf` 支持 `Swoole` 异步风格 和 `Swoole` 协程风格，在实际运行模式上，都是支持协程的，而 `Hyperf` 是配置式的，所以使用时，并没有区别。

> 当我们使用 异步风格 `SWOOLE_BASE` 模式时，如果只设置一个进程数，也没有其他自定义进程，则会只启动一个进程，实际允许结果与 协程 风格一致。

所以对于 `Swoole` 引擎，一共有三种模式，分别是

- 协程风格
- 异步风格
  - SWOOLE_BASE
  - SWOOLE_PROCESS

### 协程风格

https://github.com/hyperf/biz-skeleton/blob/master/config/autoload/server.php#L18

我们只需要设置 `type` 为 `Hyperf\Server\CoroutineServer::class` 时，即可开启协程风格。这种方式因为只启动一个进程，所以对于 `K8s` `Swarm` 等更加友好，也不会因为自定义进程重启，导致**协程死锁**等现象的出现。 

> 协程风格只会启动一个进程，所有的自定义进程都会降级成协程进行处理。

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
use Hyperf\Engine\Constant\SocketType;
use Hyperf\Server\Event;
use Hyperf\Server\Server;

return [
    'mode' => SWOOLE_BASE,
    'type' => Hyperf\Server\CoroutineServer::class,
    'servers' => [
        [
            'name' => 'http',
            'type' => Server::SERVER_HTTP,
            'host' => '0.0.0.0',
            'port' => 9501,
            'sock_type' => SocketType::TCP,
            'callbacks' => [
                Event::ON_REQUEST => [Hyperf\HttpServer\Server::class, 'onRequest'],
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
        'max_request' => 0,
        'socket_buffer_size' => 2 * 1024 * 1024,
        'package_max_length' => 2 * 1024 * 1024,
    ],
    'callbacks' => [
        Event::ON_BEFORE_START => [Hyperf\Framework\Bootstrap\ServerStartCallback::class, 'beforeStart'],
        Event::ON_WORKER_START => [Hyperf\Framework\Bootstrap\WorkerStartCallback::class, 'onWorkerStart'],
        Event::ON_PIPE_MESSAGE => [Hyperf\Framework\Bootstrap\PipeMessageCallback::class, 'onPipeMessage'],
        Event::ON_WORKER_EXIT => [Hyperf\Framework\Bootstrap\WorkerExitCallback::class, 'onWorkerExit'],
    ],
];

```

### 异步风格 - SWOOLE_BASE

我们不设置 `type` 只设置 `mode` 即可。这种运行模式，启动的 `worker` 进程数是按照配置 `settings.worker_num` 设置的数量启动进程，如果我们设置了 `settings.max_request` 的话，

当单一 `worker` 进程处理到足够的请求后，便会重启子进程，因为通常一个项目，迭代到后期，已经不是单纯的处理 `HTTP` 服务，所以，一旦处理不好，导致协程不会自动退出，都会导致进程被主进程强杀。

所以，我建议在尽量可以的情况下，将这个配置设置为 `0`，当然，一定要处理好**内存泄漏**的问题。

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
use Hyperf\Engine\Constant\SocketType;
use Hyperf\Server\Event;
use Hyperf\Server\Server;

return [
    'mode' => SWOOLE_BASE,
    'servers' => [
        [
            'name' => 'http',
            'type' => Server::SERVER_HTTP,
            'host' => '0.0.0.0',
            'port' => 9501,
            'sock_type' => SocketType::TCP,
            'callbacks' => [
                Event::ON_REQUEST => [Hyperf\HttpServer\Server::class, 'onRequest'],
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
        'max_request' => 0,
        'socket_buffer_size' => 2 * 1024 * 1024,
        'package_max_length' => 2 * 1024 * 1024,
    ],
    'callbacks' => [
        Event::ON_BEFORE_START => [Hyperf\Framework\Bootstrap\ServerStartCallback::class, 'beforeStart'],
        Event::ON_WORKER_START => [Hyperf\Framework\Bootstrap\WorkerStartCallback::class, 'onWorkerStart'],
        Event::ON_PIPE_MESSAGE => [Hyperf\Framework\Bootstrap\PipeMessageCallback::class, 'onPipeMessage'],
        Event::ON_WORKER_EXIT => [Hyperf\Framework\Bootstrap\WorkerExitCallback::class, 'onWorkerExit'],
    ],
];

```

SWOOLE_PROCESS 模式这里笔者是不推荐的，就不做赘述了。

## 使用异常监听器

笔者发现，有些小伙伴不配置这个监听器，就会导致一些很奇怪的问题。尤其是 `PDO` 方面的问题尤为突出，从 `PHP8` 开始，`PDO` 实例销毁时，如果当时已经断连，会抛出 `WARN` 级别的错误。

但是此错误无法被默认捕获，所以就会导致 `PDO` 无法重连。所以我们需要配置这个监听器，让各种奇怪错误可以被捕获。

https://github.com/hyperf/biz-skeleton/blob/master/config/autoload/listeners.php#L13

```php
<?php

declare(strict_types=1);

return [
    Hyperf\ExceptionHandler\Listener\ErrorExceptionHandler::class,
];

```

当然，此种情况也会引起其他问题。比如以下代码

```php
<?php

$arr=[];
var_dump($arr['id']);
```

在没有配置监听器的时候，会出现一个 `NOTICE` 警告，实际输出结果是 null

而配置监听器后，则会抛出错误，所以尽量在添加此监听器时，可以跑一遍全量的测试，避免此种问题。
