# 如何让 Hyperf 只启动一个服务

众所周知 Hyperf 是不支持单独启动某个服务的，所以有类似需求的小伙伴确实比较头疼。

> 作为 Hyperf 作者，接到过很多这类需求和 PR，但都被我毙了，因为框架提供了极大的自由度，这些东西完全可以自己扩展。

以下我们提供一种极为友好的方式，处理这个问题。

[DEMO](https://github.com/Aquarmini/symfony-dispatcher-demo)

## 如何扩展

先让我们阅读一下 `Symfony\Component\Console\Application` 中的一段代码

```
$event = new ConsoleCommandEvent($command, $input, $output);
$e = null;

try {
    $this->dispatcher->dispatch($event, ConsoleEvents::COMMAND);

    if ($event->commandShouldRun()) {
        $exitCode = $command->run($input, $output);
    } else {
        $exitCode = ConsoleCommandEvent::RETURN_CODE_DISABLED;
    }
} catch (\Throwable $e) {
    $event = new ConsoleErrorEvent($input, $output, $e, $command);
    $this->dispatcher->dispatch($event, ConsoleEvents::ERROR);
    $e = $event->getError();

    if (0 === $exitCode = $event->getExitCode()) {
        $e = null;
    }
}
```

可以看到，我们在执行具体的 `Command` 前，会先触发 `ConsoleCommandEvent` 事件，那么我们只需要写一个 `Listener`，来触发这个事件即可。

## 编写 Listener

我们从 `$event` 中拿到对应的 `Command`，然后添加我们的需要自定义的选项，然后重载以下 `InputInterface`。

接下来我们只需要根据对应的 `Option` 修改 `Config` 中的配置即可。

代码如下

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

use App\Constants\ErrorCode;
use App\Exception\BusinessException;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Psr\Container\ContainerInterface;
use Symfony\Component\Console\Event\ConsoleCommandEvent;
use Symfony\Component\Console\Input\InputOption;

/**
 * @Listener
 */
class ConsoleCommandEventListener implements ListenerInterface
{
    /**
     * @var ContainerInterface
     */
    private $container;

    public function __construct(ContainerInterface $container)
    {
        $this->container = $container;
    }

    public function listen(): array
    {
        return [
            ConsoleCommandEvent::class,
        ];
    }

    /**
     * @param ConsoleCommandEvent $event
     */
    public function process(object $event)
    {
        if ($event instanceof ConsoleCommandEvent) {
            $command = $event->getCommand();
            $command->addOption('server', 'S', InputOption::VALUE_OPTIONAL, '需要启动的服务');
            $input = $event->getInput();
            $input->bind($command->getDefinition());

            if ($input->getOption('server') != null) {
                $config = $this->container->get(ConfigInterface::class);
                $servers = $config->get('server.servers', []);
                $result = [];
                foreach ($servers as $server) {
                    if ($input->getOption('server') == $server['name']) {
                        $result[] = $server;
                    }
                }

                if (empty($result)) {
                    throw new BusinessException(ErrorCode::SERVER_ERROR, '服务名不存在');
                }

                $config->set('server.servers', $result);
            }
        }
    }
}

```

测试结果如下，可见符合我们的预期

```
$ php bin/hyperf.php start
[INFO] HTTP Server listening at 0.0.0.0:9502
[INFO] HTTP Server listening at 0.0.0.0:9501
^C

$ php bin/hyperf.php start -S http
[INFO] HTTP Server listening at 0.0.0.0:9501
^C

$ php bin/hyperf.php start -S http2
[INFO] HTTP Server listening at 0.0.0.0:9502
^C

```

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.5+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。