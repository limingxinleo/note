# 配合 微信机器人 使用 RPC 服务

## 相关文章

- [配合微信机器人使用 AI 大语言模型](blogs/how-to-use-ai-in-wechat-bot.md)

既然我们在上篇文章中，介绍了微信机器人的使用方法，那么，大家肯定会想到，微信机器人除了可以当做机器人帮忙处理一些事情，还可以用来做通知机器人。

所以，今天我们来做一个简单的 Demo，实现机器人的通知功能。

## 为什么使用 RPC

我们之前其实也看到了，微信机器人实际上的运行模式，还是模拟一个 web端 的微信，所以部署多份意义不太大，当然，我们已经将信息都放到 Redis 中了，想要部署多机实例也是可以的。

但是我们没有进行同步的数据，比如用户列表等等，就会多多少少还有很多需要改动的地方。

比如现在 vbot 更新好友的逻辑，是触发到对应的加好友等操作后，直接修改了内存，默认情况下是不支持分布式的。

综上，在数据量不大的情况下，一个节点部署一个微信机器人还是合理的，就算后期要大批量使用，也可以多搞几个节点，每个节点接入不同的微信。

## 设计一个通用的 RPC 接口

1. 安装 RPC 相关组件

> 整个项目使用的是 Hyperf 3.1 版本，所以以下安装示例，皆以 3.1 为准

```shell
# 多路复用的 RPC 组件
composer require "hyperf/rpc-multiplex:3.1.*" -W
# 记录 RPC 调用日志的组件
composer require hyperf/rpc-log-listener
```

2. 发布配置

首先在 `config/autoload/server.php` 配置中增加 RPC 相关的配置

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
        ],
        [
            'name' => 'rpc',
            'type' => Server::SERVER_BASE,
            'host' => '0.0.0.0',
            'port' => 9502,
            'sock_type' => SWOOLE_SOCK_TCP,
            'callbacks' => [
                Event::ON_RECEIVE => [Hyperf\RpcMultiplex\TcpServer::class, 'onReceive'],
            ],
            'settings' => [
                'open_length_check' => true,
                'package_length_type' => 'N',
                'package_length_offset' => 0,
                'package_body_offset' => 4,
                'package_max_length' => 1024 * 1024 * 2,
            ],
            'options' => [
                'send_channel_capacity' => 65535,
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

修改 `config/autoload/services.php` 中，增加对应的消费者

```php
<?php

declare(strict_types=1);

use App\RPC\Contract\ChatBotInterface;
use Hyperf\RpcMultiplex\Constant;

use function Hyperf\Support\env;

return [
    'consumers' => [
        [
            'name' => ChatBotInterface::class,
            'service' => ChatBotInterface::class,
            'id' => ChatBotInterface::class,
            'protocol' => Constant::PROTOCOL_DEFAULT,
            'load_balancer' => 'random',
            'nodes' => [['host' => env('CHAT_BOT_HOST', 'chat-bot'), 'port' => 9502]],
            'options' => [
                'connect_timeout' => 5.0,
                'recv_timeout' => 5,
                'settings' => [
                    // 包体最大值，若小于 Server 返回的数据大小，则会抛出异常，故尽量控制包体大小
                    'package_max_length' => 1024 * 1024 * 2,
                ],
                // 重试次数，默认值为 2
                'retry_count' => 2,
                // 重试间隔，毫秒
                'retry_interval' => 10,
                // 多路复用客户端数量
                'client_count' => 4,
                // 心跳间隔
                'heartbeat' => 20,
            ],
        ],
    ],
];

```

修改本地 `.env` 配置，追加以下配置项

```dotenv
# Development
CHAT_BOT_HOST=127.0.0.1
```

接下来增加 `ChatBotInterface` 和 `ChatBotService` 实现

```php
<?php

declare(strict_types=1);

namespace App\RPC\Contract;

use JetBrains\PhpStorm\ArrayShape;

interface ChatBotInterface
{
    public function sendText(
        #[ArrayShape(['nickname' => 'string'])]
        array $user,
        string $message
    ): bool;
}

```

```php
<?php

declare(strict_types=1);

namespace App\RPC;

use App\RPC\Contract\ChatBotInterface;
use Hyperf\RpcMultiplex\Constant;
use Hyperf\RpcServer\Annotation\RpcService;
use JetBrains\PhpStorm\ArrayShape;

#[RpcService(name: ChatBotInterface::class, server: 'rpc', protocol: Constant::PROTOCOL_DEFAULT)]
class ChatBotService implements ChatBotInterface
{
    public function sendText(
        #[ArrayShape(['nickname' => 'string'])] array $user,
        string $message
    ): bool {
        return true;
    }
}

```

接下来我们写一个测试脚本

```php
<?php

declare(strict_types=1);

namespace App\Command;

use App\RPC\Contract\ChatBotInterface;
use Hyperf\Command\Annotation\Command;
use Hyperf\Command\Command as HyperfCommand;
use Psr\Container\ContainerInterface;

#[Command]
class TestCommand extends HyperfCommand
{
    public function __construct(protected ContainerInterface $container)
    {
        parent::__construct('test');
    }

    public function configure()
    {
        parent::configure();
        $this->setDescription('测试脚本');
    }

    public function handle()
    {
        $res = di()->get(ChatBotInterface::class)->sendText(['nickname' => 'limingxinleo'], 'Hell World');

        var_dump($res);
    }
}

```

最后只需要启动服务，运行脚本，就能看到实际效果了。

## 新建另外一个项目

我们既然已经单机测试通过了，接下来就是创建另外一个服务，进行跨服务调用了。

### 复制 RPC 接口文件和配置

> 当然，这里有很多种方式，我们也可以把所有的 RPC 接口文件都放到一个 composer 包里，需要用到的时候直接进行 require 引入，这里为了方便就直接进行复制了。

1. 安装组件，同上
2. 复制 ChatBotInterface，路径同上
3. 复制 `config/autoload/services.php`，内容同上
4. 复制 `.env` 相关配置，内容同上，如果我们两个服务都跑在 `Swarm` 或者 `K8s` 中，则可以跳过此项，只需要定义 机器人项目 的服务名为 `chat-bot` 即可。
5. 最后只需要把 `TestCommand` 整套测试代码搬过来，即可测试。

## 小节

本套教程已全部结束，后续还会有成套教程出现，不过也都是面向初中级开发者的。
