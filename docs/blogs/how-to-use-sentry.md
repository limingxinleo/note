# 如何使用 Sentry

这里我们使用 [sentry](https://github.com/friendsofhyperf/sentry) 组件包来为 `Hyperf` 框架提供接入 `Sentry` 的能力。

## 准备工作

我们接下来需要准备好 Sentry 服务和用于测试的 Demo 项目，当然，已经有 `Sentry` 服务和 `Hyperf` 项目的同学，可以跳过这一部分。

1. 安装 Sentry

私有化部署还是有点麻烦的，这里我们为了方便测试，直接去 [sentry.io](https://sentry.io) 注册一个账户。

接下来创建一个 `Project`，点击设置

![](https://foruda.gitee.com/images/1699967730484194249/15a54d69_775029.png)

找到对应的 `DSN`，在后面会用到

![](https://foruda.gitee.com/images/1699967821635421894/fa09d1d0_775029.png)

2. 安装 Hyperf 项目

因为这个组件包仅支持 Hyperf 3.0 和 3.1 版本，所以我们直接安装一个最新的骨架包，毕竟 3.1 快发布了，谁还用 3.0 啊？

```shell
composer create hyperf/biz-skeleton sentry-demo dev-master
```

## 开始测试

1. 安装组件

```shell
composer require friendsofhyperf/sentry
php bin/hyperf.php vendor:publish friendsofhyperf/sentry
```

2. 完善配置

修改 `.env` 增加一下环境变量

```dotenv
# Sentry
SENTRY_DSN=""
```

修改 `config/autoload/server.php` 配置，增加 `enable_request_lifecycle` 配置，这个配置会开启请求级别的监听。

Sentry 组件将会自动收集请求日志，并投递到 Sentry 服务中。

```php
<?php

declare(strict_types=1);

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
            'options' => [
                'enable_request_lifecycle' => true,
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

3. 修改逻辑代码

修改 `app/Controller/IndexController` 中的代码，我们直接抛出错误

```php
<?php

declare(strict_types=1);

namespace App\Controller;

use App\Constants\ErrorCode;
use App\Exception\BusinessException;

class IndexController extends Controller
{
    public function index()
    {
        throw new BusinessException(ErrorCode::SERVER_ERROR, '未知错误');
    }
}

```

4. 启动服务，然后测试

就可以在 Sentry 服务中看到我们的错误日志了

![](https://foruda.gitee.com/images/1699968564880937775/10abda15_775029.png)

![](https://foruda.gitee.com/images/1699968615914659077/aaf98996_775029.png)
