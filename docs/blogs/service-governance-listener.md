# 如何区别本地和线上环境，针对不同环境发布服务到 Consul

如何在不修改源码的前提下

使本地环境的 JSONRPC 服务不发布到注册中心

而线上环境不受任何影响

> 以下代码片段，全部省略不想干的部分

## 原因

让我们修改源码 `Hyperf\ServiceGovernance\Listener\RegisterServiceListener`

```
public function process(object $event)
{
    $this->registeredServices = [];
    $continue = true;
    while ($continue) {
        dump(__METHOD__);
    }
}
```

启动服务后，我们便可以看到

```
$ php bin/hyperf.php start
"Hyperf\ServiceGovernance\Listener\RegisterServiceListener::process"
[INFO] HTTP Server listening at 0.0.0.0:9501
```

源码中我们可以清楚的看到，监听器会监听 `MainWorkerStart` 和 `MainCoroutineServerStart` 事件

然后执行 `process()` 方法，故会执行发布服务到注册中心的逻辑

那我们的解决办法，就是可以拦截这里，达到我们的效果。

## 解决方案

### 使用 AOP

无侵入修改代码，我们立刻会想到使用 AOP 来实现，让我们编写一个 `RegisterServiceAspect`

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
namespace App\Aspect;

use Hyperf\Di\Annotation\Aspect;
use Hyperf\Di\Aop\AbstractAspect;
use Hyperf\Di\Aop\ProceedingJoinPoint;
use Hyperf\ServiceGovernance\Listener\RegisterServiceListener;
use Psr\Container\ContainerInterface;

/**
 * @Aspect
 */
class RegisterServiceAspect extends AbstractAspect
{
    protected $container;

    public $classes = [
        RegisterServiceListener::class . '::process',
    ];

    public function __construct(ContainerInterface $container)
    {
        $this->container = $container;
    }

    public function process(ProceedingJoinPoint $proceedingJoinPoint)
    {
        // 此处判断可以根据实际情况而定，比如读取某个配置等
        if (env('APP_ENV') === 'prod') {
            return $proceedingJoinPoint->process();
        }
    }
}
```

再让我们执行代码便可以看到，不会再次打印 `__METHOD__` 了。

### 类映射

当然，除了上述办法，还有一种更加简便的方法，让我们直接重写一个 RegisterServiceListener

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
namespace App\Listener;

use Hyperf\ServiceGovernance\Listener\RegisterServiceListener as ServiceListener;

class RegisterServiceListener extends ServiceListener
{
    public function process(object $event)
    {
        if (env('APP_ENV') === 'prod') {
            return parent::process();
        }
    }
}
```

接下来修改 `dependencies.php`

```php
<?php

declare(strict_types=1);

return [
    Hyperf\ServiceGovernance\Listener\RegisterServiceListener::class => App\Listener\RegisterServiceListener::class,
];
```

再次运行代码，便可以看到效果了。
