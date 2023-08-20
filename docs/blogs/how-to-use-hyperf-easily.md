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



