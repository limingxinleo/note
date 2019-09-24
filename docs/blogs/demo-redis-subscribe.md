# 基于Redis的订阅与发布

`Hyperf` 已经实现了基于 `AMQP` 的订阅与发布，这里给大家实现另外一种方式，来玩一下 `Redis` 的订阅与发布。

> 此方法在订阅与发布中，不是最优选，所以框架并没有支持。如果是线上项目还是推荐使用 `AMQP` 来做消息队列。

## Github仓库

[demo-redis-subscribe](https://github.com/Aquarmini/demo-redis-subscribe.git)

## 创建项目

```
$ composer create hyperf/biz-skeleton demo-redis-subscribe dev-master
Installing hyperf/biz-skeleton (dev-master 1eaa35a957cf704a5c9959c68e426a614c7598a2)
  - Installing hyperf/biz-skeleton (dev-master 1eaa35a): Cloning 1eaa35a957 from cache
Created project in demo-redis-subscribe
> @php -r "file_exists('.env') || copy('.env.example', '.env');"
Loading composer repositories with package information
Updating dependencies (including require-dev)
Package operations: 133 installs, 0 updates, 0 removals
  - Installing ocramius/package-versions (1.4.0): Loading from cache
  - Installing hyperf/contract (dev-master 1624d1c): Cloning 1624d1ce0e from cache
  - Installing doctrine/inflector (v1.3.0): Loading from cache
  - Installing hyperf/utils (dev-master c847116): Cloning c847116cf9 from cache
  - Installing psr/container (1.0.0): Loading from cache
  - Installing hyperf/pool (dev-master 5a67570): Cloning 5a67570f71 from cache
  - Installing psr/event-dispatcher (1.0.0): Loading from cache
  - Installing hyperf/process (dev-master 75f4fbf): Cloning 75f4fbfa56 from cache
  - Installing doctrine/instantiator (1.2.0): Loading from cache
  - Installing psr/log (1.1.0): Loading from cache
  - Installing php-amqplib/php-amqplib (v2.10.0): Loading from cache
  - Installing hyperf/amqp (dev-master 1cff378): Cloning 1cff378bc4 from cache
  - Installing symfony/service-contracts (v1.1.6): Loading from cache
  - Installing symfony/polyfill-php73 (v1.12.0): Loading from cache
  - Installing symfony/polyfill-mbstring (v1.12.0): Loading from cache
  - Installing symfony/console (v4.3.4): Loading from cache
  - Installing hyperf/command (dev-master e4caea4): Cloning e4caea4c70 from cache
  - Installing hyperf/async-queue (dev-master 8d28229): Cloning 8d282297cd from cache
  - Installing psr/simple-cache (1.0.1): Loading from cache
  - Installing hyperf/cache (dev-master 60997fb): Cloning 60997fb05c from cache
  - Installing hyperf/circuit-breaker (dev-master e41726f): Cloning e41726fd25 from cache
  - Installing symfony/finder (v4.3.4): Loading from cache
  - Installing symfony/polyfill-ctype (v1.12.0): Loading from cache
  - Installing phpoption/phpoption (1.5.0): Loading from cache
  - Installing vlucas/phpdotenv (v3.6.0): Loading from cache
  - Installing hyperf/config (dev-master 44f5ef8): Cloning 44f5ef8a10 from cache
  - Installing psr/http-message (1.0.1): Loading from cache
  - Installing fig/http-message-util (1.1.3): Loading from cache
  - Installing hyperf/framework (dev-master 3be169b): Cloning 3be169b9f4 from cache
  - Installing hyperf/event (dev-master e9d97f1): Cloning e9d97f11fb from cache
  - Installing php-di/phpdoc-reader (2.1.0): Loading from cache
  - Installing doctrine/lexer (1.1.0): Loading from cache
  - Installing doctrine/annotations (v1.7.0): Loading from cache
  - Installing nikic/php-parser (v4.2.4): Loading from cache
  - Installing hyperf/di (dev-master 7f82227): Cloning 7f822276a0 from cache
  - Installing hyperf/constants (dev-master a3baaf8): Cloning a3baaf8bbd from cache
  - Installing hyperf/devtool (dev-master c3f424f): Cloning c3f424f2c6 from cache
  - Installing ralouphie/getallheaders (3.0.3): Loading from cache
  - Installing guzzlehttp/psr7 (1.6.1): Loading from cache
  - Installing guzzlehttp/promises (v1.3.1): Loading from cache
  - Installing guzzlehttp/guzzle (6.3.3): Loading from cache
  - Installing hyperf/guzzle (dev-master 90ad6e4): Cloning 90ad6e497b from cache
  - Installing react/promise (v2.7.1): Loading from cache
  - Installing guzzlehttp/streams (3.0.0): Loading from cache
  - Installing guzzlehttp/ringphp (1.1.1): Loading from cache
  - Installing elasticsearch/elasticsearch (v6.7.2): Loading from cache
  - Installing hyperf/elasticsearch (dev-master c936fc0): Cloning c936fc0f24 from cache
  - Installing monolog/monolog (1.25.1): Loading from cache
  - Installing hyperf/logger (dev-master 937101c): Cloning 937101c682 from cache
  - Installing hyperf/memory (dev-master 17003ec): Cloning 17003ec1e9 from cache
  - Installing hyperf/paginator (dev-master 4ffeb0e): Cloning 4ffeb0e46c from cache
  - Installing symfony/translation-contracts (v1.1.6): Loading from cache
  - Installing symfony/translation (v4.3.4): Loading from cache
  - Installing nesbot/carbon (2.24.0): Loading from cache
  - Installing hyperf/database (dev-master d36785e): Cloning d36785e709 from cache
  - Installing hyperf/model-listener (dev-master 5a77c83): Cloning 5a77c83cbe from cache
  - Installing hyperf/db-connection (dev-master 17eec65): Cloning 17eec65d60 from cache
  - Installing hyperf/model-cache (dev-master e3c5293): Cloning e3c5293a56 from cache
  - Installing hyperf/redis (dev-master 6043083): Cloning 6043083650 from cache
  - Installing hyperf/server (dev-master b0c8bd9): Cloning b0c8bd9e92 from cache
  - Installing zendframework/zend-stdlib (3.2.1): Loading from cache
  - Installing zendframework/zend-mime (2.7.1): Loading from cache
  - Installing hyperf/http-message (dev-master dcd1d78): Cloning dcd1d78b88 from cache
  - Installing psr/http-server-handler (1.0.1): Loading from cache
  - Installing psr/http-server-middleware (1.0.1): Loading from cache
  - Installing hyperf/dispatcher (dev-master 670f7dc): Cloning 670f7dca4f from cache
  - Installing hyperf/exception-handler (dev-master d1f3511): Cloning d1f3511c9c from cache
  - Installing nikic/fast-route (v1.3.0): Loading from cache
  - Installing hyperf/http-server (dev-master 2744b1a): Cloning 2744b1a949 from cache
  - Installing phpunit/php-timer (2.1.2): Loading from cache
  - Installing sebastian/environment (4.2.2): Loading from cache
  - Installing sebastian/version (2.0.1): Loading from cache
  - Installing sebastian/resource-operations (2.0.1): Loading from cache
  - Installing sebastian/object-reflector (1.1.1): Loading from cache
  - Installing sebastian/recursion-context (3.0.0): Loading from cache
  - Installing sebastian/object-enumerator (3.0.3): Loading from cache
  - Installing sebastian/global-state (2.0.0): Loading from cache
  - Installing sebastian/exporter (3.1.2): Loading from cache
  - Installing sebastian/diff (3.0.2): Loading from cache
  - Installing sebastian/comparator (3.0.2): Loading from cache
  - Installing phpunit/php-text-template (1.2.1): Loading from cache
  - Installing phpunit/php-file-iterator (2.0.2): Loading from cache
  - Installing theseer/tokenizer (1.1.3): Loading from cache
  - Installing sebastian/code-unit-reverse-lookup (1.0.1): Loading from cache
  - Installing phpunit/php-token-stream (3.1.1): Loading from cache
  - Installing phpunit/php-code-coverage (6.1.4): Loading from cache
  - Installing webmozart/assert (1.5.0): Loading from cache
  - Installing phpdocumentor/reflection-common (2.0.0): Loading from cache
  - Installing phpdocumentor/type-resolver (1.0.1): Loading from cache
  - Installing phpdocumentor/reflection-docblock (4.3.2): Loading from cache
  - Installing phpspec/prophecy (1.8.1): Loading from cache
  - Installing phar-io/version (2.0.1): Loading from cache
  - Installing phar-io/manifest (1.0.3): Loading from cache
  - Installing myclabs/deep-copy (1.9.3): Loading from cache
  - Installing phpunit/phpunit (7.5.16): Loading from cache
  - Installing hyperf/testing (dev-master 910f9e9): Cloning 910f9e94db from cache
  - Installing swoft/swoole-ide-helper (v4.4.6): Loading from cache
  - Installing symfony/filesystem (v4.3.4): Loading from cache
  - Installing symfony/config (v4.3.4): Loading from cache
  - Installing symfony/dependency-injection (v4.3.4): Loading from cache
  - Installing pdepend/pdepend (2.5.2): Loading from cache
  - Installing phpmd/phpmd (2.7.0): Loading from cache
  - Installing symfony/stopwatch (v4.3.4): Loading from cache
  - Installing symfony/process (v4.3.4): Loading from cache
  - Installing symfony/polyfill-php72 (v1.12.0): Loading from cache
  - Installing paragonie/random_compat (v9.99.99): Loading from cache
  - Installing symfony/polyfill-php70 (v1.12.0): Loading from cache
  - Installing symfony/options-resolver (v4.3.4): Loading from cache
  - Installing symfony/event-dispatcher-contracts (v1.1.5): Loading from cache
  - Installing symfony/event-dispatcher (v4.3.4): Loading from cache
  - Installing php-cs-fixer/diff (v1.3.0): Loading from cache
  - Installing composer/xdebug-handler (1.3.3): Loading from cache
  - Installing composer/semver (1.5.0): Loading from cache
  - Installing friendsofphp/php-cs-fixer (v2.15.3): Loading from cache
  - Installing hamcrest/hamcrest-php (v2.0.0): Loading from cache
  - Installing mockery/mockery (1.2.3): Loading from cache
  - Installing doctrine/reflection (v1.0.0): Loading from cache
  - Installing doctrine/event-manager (v1.0.0): Loading from cache
  - Installing doctrine/collections (v1.6.2): Loading from cache
  - Installing doctrine/cache (v1.8.0): Loading from cache
  - Installing doctrine/persistence (1.1.1): Loading from cache
  - Installing doctrine/common (v2.11.0): Loading from cache
  - Installing phpstan/phpdoc-parser (0.3.5): Loading from cache
  - Installing nette/utils (v3.0.1): Loading from cache
  - Installing nette/schema (v1.0.0): Loading from cache
  - Installing nette/finder (v2.5.1): Loading from cache
  - Installing nette/robot-loader (v3.2.0): Loading from cache
  - Installing nette/php-generator (v3.2.3): Loading from cache
  - Installing nette/neon (v3.0.0): Loading from cache
  - Installing nette/di (v3.0.1): Loading from cache
  - Installing nette/bootstrap (v3.0.0): Loading from cache
  - Installing jean85/pretty-package-versions (1.2): Loading from cache
  - Installing phpstan/phpstan (0.11.16): Loading from cache
hyperf/utils suggests installing symfony/var-dumper (Required to use the dd function (^4.1).)
hyperf/utils suggests installing symfony/serializer (Required to use SymfonyNormalizer (^4.3))
hyperf/utils suggests installing symfony/property-access (Required to use SymfonyNormalizer (^4.3))
symfony/console suggests installing symfony/lock
guzzlehttp/psr7 suggests installing zendframework/zend-httphandlerrunner (Emit PSR-7 responses)
monolog/monolog suggests installing graylog2/gelf-php (Allow sending log messages to a GrayLog2 server)
monolog/monolog suggests installing sentry/sentry (Allow sending log messages to a Sentry server)
monolog/monolog suggests installing doctrine/couchdb (Allow sending log messages to a CouchDB server)
monolog/monolog suggests installing ruflin/elastica (Allow sending log messages to an Elastic Search server)
monolog/monolog suggests installing ext-amqp (Allow sending log messages to an AMQP server (1.0+ required))
monolog/monolog suggests installing ext-mongo (Allow sending log messages to a MongoDB server)
monolog/monolog suggests installing mongodb/mongodb (Allow sending log messages to a MongoDB server via PHP Driver)
monolog/monolog suggests installing aws/aws-sdk-php (Allow sending log messages to AWS services like DynamoDB)
monolog/monolog suggests installing rollbar/rollbar (Allow sending log messages to Rollbar)
monolog/monolog suggests installing php-console/php-console (Allow sending log messages to Google Chrome)
symfony/translation suggests installing symfony/yaml
hyperf/database suggests installing doctrine/dbal (Required to rename columns (^2.6).)
zendframework/zend-mime suggests installing zendframework/zend-mail (Zend\Mail component)
sebastian/global-state suggests installing ext-uopz (*)
phpunit/php-code-coverage suggests installing ext-xdebug (^2.6.0)
phpunit/phpunit suggests installing phpunit/php-invoker (^2.0)
phpunit/phpunit suggests installing ext-xdebug (*)
symfony/config suggests installing symfony/yaml (To use the yaml reference dumper)
symfony/dependency-injection suggests installing symfony/yaml
symfony/dependency-injection suggests installing symfony/expression-language (For using expressions in service container configuration)
symfony/dependency-injection suggests installing symfony/proxy-manager-bridge (Generate service proxies to lazy load them)
paragonie/random_compat suggests installing ext-libsodium (Provides a modern crypto API that can be used to generate random bytes.)
symfony/event-dispatcher suggests installing symfony/http-kernel
friendsofphp/php-cs-fixer suggests installing php-cs-fixer/phpunit-constraint-isidenticalstring (For IsIdenticalString constraint.)
friendsofphp/php-cs-fixer suggests installing php-cs-fixer/phpunit-constraint-xmlmatchesxsd (For XmlMatchesXsd constraint.)
doctrine/cache suggests installing alcaeus/mongo-php-adapter (Required to use legacy MongoDB driver)
nette/bootstrap suggests installing tracy/tracy (to use Configurator::enableTracy())
Writing lock file
Generating autoload files
ocramius/package-versions:  Generating version class...
ocramius/package-versions: ...done generating version class
Do you want to remove the existing VCS (.git, .svn..) history? [Y,n]? Y
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
 * @Process(name="RedisConsumerProgress")
 */
class RedisConsumerProgress extends AbstractProcess
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

### 未完待续

...

### 写在最后

![](https://cdn.learnku.com/uploads/images/201906/29/19883/onNKmy8Ga8.jpeg!large)

