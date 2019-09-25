# 基于Redis的订阅与发布

`Hyperf` 已经实现了基于 `AMQP` 的订阅与发布，这里给大家实现另外一种方式，来玩一下 `Redis` 的订阅与发布。

> 此方法在订阅与发布中，不是最优选，所以框架并没有支持。如果是线上项目还是推荐使用 `AMQP` 来做消息队列。

## Github仓库

[demo-redis-subscribe](https://github.com/Aquarmini/demo-redis-subscribe.git)

## 创建项目

```
$ composer create hyperf/biz-skeleton demo-redis-subscribe dev-master
```

## 定义队列

我们希望可以监听多个队列，所以便把队列名字额外定义出来。

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE
 */

namespace App\Constants;

class Channel
{
    const QUEUE = 'channel.queue';

    const TEST = 'channel.test';

    public static function getArray()
    {
        return [
            self::QUEUE,
            self::TEST,
        ];
    }
}

```

## 创建用于订阅的 Redis 实例

### 更新配置

`autoload/redis.php` 中新增 `subscriber` 相关配置

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE
 */

return [
    'default' => [
        'host' => env('REDIS_HOST', 'localhost'),
        'auth' => env('REDIS_AUTH', null),
        'port' => (int) env('REDIS_PORT', 6379),
        'db' => (int) env('REDIS_DB', 0),
        'pool' => [
            'min_connections' => 1,
            'max_connections' => 10,
            'connect_timeout' => 10.0,
            'wait_timeout' => 3.0,
            'heartbeat' => -1,
            'max_idle_time' => (float) env('REDIS_MAX_IDLE_TIME', 60),
        ],
    ],
    'subscriber' => [
        'host' => env('REDIS_HOST', 'localhost'),
        'auth' => env('REDIS_AUTH', null),
        'port' => (int) env('REDIS_PORT', 6379),
        'db' => (int) env('REDIS_DB', 0),
        'options' => [
            \Redis::OPT_READ_TIMEOUT => '-1',
        ],
        'pool' => [
            'min_connections' => 1,
            'max_connections' => 10,
            'connect_timeout' => 10.0,
            'wait_timeout' => 3.0,
            'heartbeat' => -1,
            'max_idle_time' => (float) env('REDIS_MAX_IDLE_TIME', 60),
        ],
    ],
];

```

### 增加 `Subscriber` 客户端

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE
 */

namespace App\Kernel;

use Hyperf\Redis\Redis;

class Subscriber extends Redis
{
    protected $poolName = 'subscriber';
}

```

### 增加消费进程

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE
 */

namespace App\Process;

use App\Constants\Channel;
use App\Kernel\Subscriber;
use Hyperf\Process\AbstractProcess;
use Hyperf\Process\Annotation\Process;

/**
 * @Process(name="RedisConsumer")
 */
class RedisConsumerProcess extends AbstractProcess
{
    public function handle(): void
    {
        $redis = di()->get(Subscriber::class);

        $redis->subscribe(Channel::getArray(), function ($instance, $channelName, $message) {
            var_dump($instance);
            var_dump($channelName);
            var_dump($message);

            // TODO: 执行对应的消费操作
        });
    }
}

```

## 测试代码

修改 `IndexController` 如下

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE
 */

namespace App\Controller;

use App\Constants\Channel;

class IndexController extends Controller
{
    public function index()
    {
        $user = $this->request->input('user', 'Hyperf');
        $method = $this->request->getMethod();

        $redis = di()->get(\Redis::class);

        $redis->publish(Channel::TEST, $user);

        return $this->response->success([
            'user' => $user,
            'method' => $method,
            'message' => 'Hello Hyperf.',
        ]);
    }
}

```

启动 Server，测试结果

```
$ curl http://127.0.0.1:9501/
{"code":0,"data":{"user":"Hyperf","method":"GET","message":"Hello Hyperf."}}

终端显示如下

object(Redis)#47173 (0) {
}
string(12) "channel.test"
string(6) "Hyperf"

```

## 未完待续

...

## 写在最后

![](https://cdn.learnku.com/uploads/images/201906/29/19883/onNKmy8Ga8.jpeg!large)

