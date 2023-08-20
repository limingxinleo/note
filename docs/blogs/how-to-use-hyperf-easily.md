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


