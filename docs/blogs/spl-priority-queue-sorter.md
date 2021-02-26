# 基于 SplPriorityQueue 实现的排序方法

[limingxinleo/hyperf-utils](https://github.com/limingxinleo/hyperf-utils)

## 前言

之前我们在进行数组排序时，经常使用 `usort` `ksort` 等方法，但当我们排序规则复杂一些后，这些方法使用起来就不是那么的方便了。

后来发现了 `\SplPriorityQueue`，进行简单的封装后，就更加方便使用了。

## 基础封装

`Laminas\Stdlib\SplPriorityQueue` 是对 `\SplPriorityQueue` 的封装，更加方便使用。

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
namespace Han\Utils\Utils;

use Laminas\Stdlib\SplPriorityQueue;

class Sorter
{
    /**
     * @param array|\iterable $items
     */
    public function sort($items, callable $callable): SplPriorityQueue
    {
        $queue = new SplPriorityQueue();
        $serial = PHP_INT_MAX;
        foreach ($items as $item) {
            $priority = (array) $callable($item);
            $priority[] = $serial--;
            $queue->insert($item, $priority);
        }
        return $queue;
    }
}

```

上述代码，可以看到，我们额外增加了参数 `$serial`，这个字段会让 `$priority` 一致的元素可以按照优先插入元素的顺序排序。

## 代码测试

我们只需要调用 `sort` 方法，然后在后面的匿名函数中返回对应元素的权重即可。

```php
<?php

$col = new Collection([
    new ModelStub(['id' => 1, 'message' => $id = uniqid()]),
    new ModelStub(['id' => 2, 'message' => $id2 = uniqid()]),
]);

$sorter = new Sorter();
$res = $sorter->sort($col, static function (ModelStub $model) {
    return $model->id;
});

$data = $res->toArray();
$this->assertSame(2, $data[0]->id);
$this->assertSame(1, $data[1]->id);
$this->assertSame($id2, $data[0]->message);
$this->assertSame($id, $data[1]->message);
```

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.5+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。