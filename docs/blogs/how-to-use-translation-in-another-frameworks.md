# 如何在其他框架中使用 Hyperf 国际化组件

前段时间有同学在群里提问，如果在其他框架里引用 `Hyperf` 国际化组件，并提供了对应的 [ISSUE](https://github.com/hyperf/hyperf/issues/1485)

`Issue` 中的错误其实很简单，就是 `Hyperf\Utils\ApplicationContext` 中没有存入对应的 `Container`，为了更方便的接入 `Hyperf` 其他的组件，`Hyperf` 官方提供了一个新的组件 [hyperf/pimple](https://github.com/hyperf-cloud/pimple-integration)。

这是一个基于 `pimple/pimple` 实现的符合 `PSR11` 规范的容器组件。接下来让我正式开始接入 国际化组件，以下以 `EasySwoole` 为例。

## 接入指南

因为 `EasySwoole` 的容器组件暂时并没有实现 `PSR11` 规范，所以无法直接使用。

- 首先引入相关组件

```
composer require "hyperf/pimple:1.1.*"
composer require "hyperf/translation:1.1.*"
composer require "hyperf/config:1.1.*"
```

- 添加 国际化相关的 Provider

TranslatorLoaderProvider

```php
<?php

declare(strict_types=1);

namespace App\Provider;

use Hyperf\Contract\ConfigInterface;
use Hyperf\Contract\ContainerInterface;
use Hyperf\Contract\TranslatorLoaderInterface;
use Hyperf\Pimple\ProviderInterface;
use Hyperf\Translation\FileLoader;
use Hyperf\Utils\Filesystem\Filesystem;

class TranslatorLoaderProvider implements ProviderInterface
{
    public function register(ContainerInterface $container)
    {
        $container->set(TranslatorLoaderInterface::class, function () use ($container) {
            $config = $container->get(ConfigInterface::class);
            $files = $container->get(Filesystem::class);
            $path = $config->get('translation.path');

            return make(FileLoader::class, compact('files', 'path'));
        });
    }
}
```

TranslatorProvider

```php
<?php

declare(strict_types=1);

namespace App\Provider;

use Hyperf\Contract\ConfigInterface;
use Hyperf\Contract\ContainerInterface;
use Hyperf\Contract\TranslatorInterface;
use Hyperf\Contract\TranslatorLoaderInterface;
use Hyperf\Pimple\ProviderInterface;
use Hyperf\Translation\Translator;

class TranslatorProvider implements ProviderInterface
{
    public function register(ContainerInterface $container)
    {
        $container->set(TranslatorInterface::class, function () use ($container) {
            $config = $container->get(ConfigInterface::class);
            $locale = $config->get('translation.locale');
            $fallbackLocale = $config->get('translation.fallback_locale');

            $loader = $container->get(TranslatorLoaderInterface::class);

            $translator = make(Translator::class, compact('loader', 'locale'));
            $translator->setFallback((string) $fallbackLocale);

            return $translator;
        });
    }
}

```

- `EasySwoole` 事件注册器在 `EasySwooleEvent.php` 中，所以我们需要在 `initialize()` 中初始化我们的容器和国际化组件。

> 以下 Config 组件，可以自行封装，这里方便起见直接配置。

```php
<?php

declare(strict_types=1);

namespace EasySwoole\EasySwoole;

use EasySwoole\EasySwoole\AbstractInterface\Event;
use EasySwoole\EasySwoole\Swoole\EventRegister;
use EasySwoole\Http\Request;
use EasySwoole\Http\Response;
use Hyperf\Config\Config;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Pimple\ContainerFactory;

class EasySwooleEvent implements Event
{
    public static function initialize()
    {
        date_default_timezone_set('Asia/Shanghai');
        $container = (new ContainerFactory())();
        $container->set(ConfigInterface::class, new Config([
            'translation' => [
                'locale' => 'zh_CN',
                'fallback_locale' => 'en',
                'path' => EASYSWOOLE_ROOT . '/storage/languages',
            ],
        ]));
    }
}
```

- 修改控制器，使用国际化组件

```php
<?php

declare(strict_types=1);

namespace App\HttpController;

use EasySwoole\Http\AbstractInterface\Controller;
use Hyperf\Contract\TranslatorInterface;
use Hyperf\Utils\ApplicationContext;
use Hyperf\Utils\Codec\Json;

class Index extends Controller
{
    public function index()
    {
        $container = ApplicationContext::getContainer();
        $translator = $container->get(TranslatorInterface::class);

        $data = [
            'message' => $translator->trans('message.hello', ['name' => 'Hyperf']),
        ];

        $this->response()->write(Json::encode($data));
    }
}

```

- 添加国际化配置

```php
// storage/languages/en/message.php
return [
    'hello' => 'Hello :name',
];

// storage/languages/zh_CN/message.php
return [
    'hello' => '你好 :name',
];
```

- 测试

```
$ curl http://127.0.0.1:9501/
{"message":"你好 Hyperf"}
```

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.4+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。
