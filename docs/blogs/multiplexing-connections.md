# 如何基于 Channel 实现多路复用

## 前言

首先，我们先介绍一下 `Swoole\Coroutine\Client` 的一个限制，那便是同一个连接，不允许同时被两个协程绑定，我们可以进行以下测试。

```php
<?php
run(function () {
    $client = new \Swoole\Coroutine\Client(SWOOLE_SOCK_TCP);
    $client->set([
        'open_length_check' => true,
        'package_length_type' => 'N',
        'package_length_offset' => 0,
        'package_body_offset' => 4,
        'package_max_length' => 1024 * 1024 * 2,
    ]);
    $client->connect('127.0.0.1', 9601, 0.5);
    go(function () use ($client) {
        $ret = $client->send(str_repeat('xxx', 1000));
        $client->recv();
    });
    go(function () use ($client) {
        $ret = $client->send('xxx');
        $client->recv();
    });
});
```

当我们执行以上代码，就会抛出以下错误

```
PHP Fatal error:  Uncaught Swoole\Error: Socket#9 has already been bound to another coroutine#2, reading of the same socket in coroutine#3 at the same time is not allowed in /Users/limingxin/Applications/GitHub/hyperf/repos/multiplex-socket/tests/swoole_client.php:32
Stack trace:
#0 /Users/limingxin/Applications/GitHub/hyperf/repos/multiplex-socket/tests/swoole_client.php(32): Swoole\Coroutine\Client->recv()
#1 /Users/limingxin/Applications/GitHub/hyperf/repos/multiplex-socket/vendor/hyperf/utils/src/Functions.php(271): {closure}()
#2 /Users/limingxin/Applications/GitHub/hyperf/repos/multiplex-socket/vendor/hyperf/utils/src/Coroutine.php(62): call(Object(Closure))
#3 {main}
  thrown in /Users/limingxin/Applications/GitHub/hyperf/repos/multiplex-socket/tests/swoole_client.php on line 32
```

但我们稍微改动一下代码，就不会再次报错，代码如下

```php
<?php
run(function () {
    $client = new \Swoole\Coroutine\Client(SWOOLE_SOCK_TCP);
    $client->set([
        'open_length_check' => true,
        'package_length_type' => 'N',
        'package_length_offset' => 0,
        'package_body_offset' => 4,
        'package_max_length' => 1024 * 1024 * 2,
    ]);
    $client->connect('127.0.0.1', 9601, 0.5);
    $chan = new \Swoole\Coroutine\Channel(1);
    go(function () use ($client, $chan) {
        $ret = $client->send(str_repeat('xxx', 1000));
        $chan->push(true);
        $client->recv();
        $chan->pop();
    });
    go(function () use ($client, $chan) {
        $ret = $client->send('xxx');
        $chan->push(true);
        $client->recv();
        $chan->pop();
    });
});
```

可见，我们只需要让 `recv` 在一个协程里循环调用，然后再根据收包发到不同的 `Channel` 当中，这样我们就可以多个协程复用同一个连接。

## 包体设计

接下来的事情就很简单了，我们设计一个十分简单的包结构。包头为使用 pack N 打包的包体长度，包体为 pack N 打包的 Channel ID 和 数据体。

![](http://cdn-music.lmx0536.cn/packet.jpg)

因为 Swoole 中分包规则已经实现，所以我们可以简单的配置一下实现上述效果

```
'open_length_check' => true,
'package_length_type' => 'N',
'package_length_offset' => 0,
'package_body_offset' => 4,
'package_max_length' => 1024 * 1024 * 2,
```

接下来我们只需要实现包体的 打包 和 解包功能即可，我们可以实现一个十分简单的打包器。

```php
<?php

declare(strict_types=1);

namespace Multiplex;

use Multiplex\Constract\PackerInterface;

class Packer implements PackerInterface
{
    public function pack(Packet $packet): string
    {
        return sprintf(
            '%s%s%s',
            pack('N', strlen($packet->getBody()) + 4),
            pack('N', $packet->getId()),
            $packet->getBody()
        );
    }

    public function unpack(string $data): Packet
    {
        $unpacked = unpack('Nid', substr($data, 4, 4));
        $body = substr($data, 8);
        return new Packet((int) $unpacked['id'], $body);
    }
}

```

## 服务端

服务端的设计就尤为简单了，因为 Channel 机制主要是给 客户端使用，所以服务端解包之后，原封不动的将 ChannelID 和 数据返回即可。

```php
$server->handle(function (Connection $conn) {
    while (true) {
        $ret = $conn->recv();
        if (empty($ret)) {
            break;
        }

        Coroutine::create(function () use ($ret, $conn) {
            $packet = $this->packer->unpack($ret);
            $id = $packet->getId();
            try {
                $result = $this->handler->__invoke($packet, $this->getSerializer());
            } catch (\Throwable $exception) {
                $result = $exception;
            } finally {
                $conn->send($this->packer->pack(new Packet($id, $this->getSerializer()->serialize($result))));
            }
        });
    }
});
```

## 客户端

客户端相比而言，就要麻烦一些。我们需要创建一个 Channel 存储需要 发送的数据，还需要设计一个 Channel Map 存储各个 ID 返回的数据，这样方便 recv 时，直接使用 Channel::pop() 获得数据，这样一来就可以很方便的将 业务客户端与实际客户端进行解耦。

下述代码中，我们创建了两个协程，循环调用 `Client::send` 和 `Client::recv` 方法。 

```php
protected function loop(): void
{
    if ($this->chan !== null && ! $this->chan->isClosing()) {
        return;
    }
    $this->chan = $this->getChannelManager()->make(65535);
    $this->client = $this->makeClient();
    Coroutine::create(function () {
        try {
            $chan = $this->chan;
            $client = $this->client;
            while (true) {
                $data = $client->recv();
                if (! $client->isConnected()) {
                    break;
                }
                if ($chan->isClosing()) {
                    break;
                }

                $packet = $this->packer->unpack($data);
                if ($channel = $this->getChannelManager()->get($packet->getId())) {
                    $channel->push(
                        $this->serializer->unserialize($packet->getBody())
                    );
                }
            }
        } finally {
            $chan->close();
            $client->close();
        }
    });

    Coroutine::create(function () {
        try {
            $chan = $this->chan;
            $client = $this->client;
            while (true) {
                $data = $chan->pop();
                if ($chan->isClosing()) {
                    break;
                }
                if (! $client->isConnected()) {
                    break;
                }

                if (empty($data)) {
                    continue;
                }

                $client->send($data);
            }
        } finally {
            $chan->close();
            $client->close();
        }
    });
}
```

## 实现组件

最后，根据上述的想法，我们实现了以下两个组件

[multiplex](https://github.com/hyperf/multiplex)
[multiplex-socket](https://github.com/hyperf/multiplex-socket)

随手写了两段代码，对多路复用和连接池进行测试，我们创建 10000 个协程，同时调用服务端，当服务端接收到数据，立马返回的情况下

二者差距不大，完全结束都在 0.3-0.5 秒之间。

但当我们在返回数据前，睡眠 10 毫秒的情况下，多路复用所用的时间要低于连接池的十分之一。

不仅速度更快，多路复用的连接，从始至终只用到 1 个，但连接池却起了 100 个连接，综合来说，多路复用要比使用连接池表现的更加优秀。

### 示例

客户端

```php
<?php
declare(strict_types=1);

require_once __DIR__ . '/../vendor/autoload.php';

run(function () use ($max) {
    $client = new \Multiplex\Socket\Client('127.0.0.1', 9601);
    for ($i = 0; $i < $max; ++$i) {
        go(function () use ($client, $channel) {
            $client->request('World.');
        });
    }
});
```

服务端

```php
<?php

declare(strict_types=1);

use Multiplex\Packet;
use Multiplex\Socket\Server;

require_once __DIR__ . '/../vendor/autoload.php';

run(function () {
    $server = new Server();
    $config = collect([]);
    $server->bind('0.0.0.0', 9601, $config)->handle(static function (Packet $packet) {
        return 'Hello ' . $packet->getBody();
    })->start();
});

```