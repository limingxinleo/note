# 如何定制 gen:model 命令

`Hyperf v2.0` 版本中，会将 `decimal` 转化为 `float`，从而存在精度丢失的风险。如果直接修改这个问题，可能会导致 `v2.0` 出现 `BC`，所以我们在 `v2.1` 中得到了处理，详情可见 [PR#2979](https://github.com/hyperf/hyperf/pull/2979)

但还在使用 `v2.0` 版本的同学要怎么办呢，其实我们可以通过重写 `ModelUpdateVisitor`，很简单的处理这件事。

## 创建模型

我们先在原来的情况下，执行 `gen:model`，为了后面高度定制，我们先将 `$timestamps` 设置为 `false`，这样 `created_at` 和 `updated_at` 默认都会转化为 `string`。

以下为生成的模型：

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
namespace App\Model;

/**
 * @property int $id
 * @property int $count
 * @property float $float_num
 * @property string $str
 * @property string $json
 * @property string $created_at
 * @property string $updated_at
 */
class UserExt extends Model
{
    public $timestamps = false;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'user_ext';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = ['id', 'count', 'float_num', 'str', 'json', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = ['id' => 'integer', 'count' => 'integer', 'float_num' => 'float'];
}

```

我们可以看到，`float_num` 会被 `cast` 强制转化为 `float`。

## 重写 ModelUpdateVisitor

接下来我们重写 `ModelUpdateVisitor`，将以下注释的代码删掉。

```
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
namespace App\Visitor;

use Hyperf\Database\Commands\Ast\ModelUpdateVisitor as Visitor;

class ModelUpdateVisitor extends Visitor
{
    protected function formatDatabaseType(string $type): ?string
    {
        switch ($type) {
            case 'tinyint':
            case 'smallint':
            case 'mediumint':
            case 'int':
            case 'bigint':
                return 'integer';
            // case 'decimal':
            // case 'float':
            // case 'double':
            // case 'real':
            //     return 'float';
            case 'bool':
            case 'boolean':
                return 'boolean';
            default:
                return null;
        }
    }
}

```

然后将其配置到 `dependencies.php` 中：

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
    Hyperf\Database\Commands\Ast\ModelUpdateVisitor::class => App\Visitor\ModelUpdateVisitor::class,
];
```

然后让我们重新执行 `php bin/hyperf.php gen:model --force-casts`，就可以看到，对应的 `float_num` 已经不会再转化成 `float` 了。

```php
<?php

declare (strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
namespace App\Model;

/**
 * @property int $id 
 * @property int $count 
 * @property string $float_num 
 * @property string $str 
 * @property string $json 
 * @property string $created_at 
 * @property string $updated_at 
 */
class UserExt extends Model
{
    public $timestamps = false;
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'user_ext';
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = ['id', 'count', 'float_num', 'str', 'json', 'created_at', 'updated_at'];
    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = ['id' => 'integer', 'count' => 'integer'];
}
```

当然除此之外，我们也可以通过这种方式，自动处理 `json` 和 `datetime` 格式，修改我们的 `ModelUpdateVisitor`

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
namespace App\Visitor;

use Hyperf\Database\Commands\Ast\ModelUpdateVisitor as Visitor;

class ModelUpdateVisitor extends Visitor
{
    protected function formatDatabaseType(string $type): ?string
    {
        switch ($type) {
            case 'tinyint':
            case 'smallint':
            case 'mediumint':
            case 'int':
            case 'bigint':
                return 'integer';
            case 'timestamp':
            case 'datetime':
                return 'datetime';
            case 'json':
                return 'json';
            case 'bool':
            case 'boolean':
                return 'boolean';
            default:
                return null;
        }
    }
}
```

然后重新执行 `php bin/hyperf.php gen:model --force-casts`，就可以看到结果了。

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
namespace App\Model;

/**
 * @property int $id
 * @property int $count
 * @property string $float_num
 * @property string $str
 * @property array $json
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class UserExt extends Model
{
    public $timestamps = false;

    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'user_ext';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = ['id', 'count', 'float_num', 'str', 'json', 'created_at', 'updated_at'];

    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = ['id' => 'integer', 'count' => 'integer', 'json' => 'json', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
```

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.5+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。