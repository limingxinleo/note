# 配合微信机器人使用 AI 大语言模型

今天我们讲一篇，如何配合 微信机器人 使用 AI 大语言模型，我本人对 AI 基本一窍不通，虽然近期大语言模型十分火热，但也一直没有时间去系统的学习。

今天，做一回 API 搬运工，借用 Swoole AI 来玩一下。

众所周知，微信是没有机器人的，所以我们需要借助一些其他手段，比如这个项目 [Hanson/vbot](https://github.com/Hanson/vbot) ，不过此项目对 PHP8 支持并不友好，所以我对其进行了 Hyperf 适配，
大家可以去看一下这个项目 [Gemini-D/vbot](https://github.com/Gemini-D/vbot)

## 准备工作

1. 首先，我们需要准备一个测试机，因为 vbot 是模拟 web 端微信实现的，所以要求我们的微信必须一直在线。
2. 其次，准备一个不常用的微信号。

## 开始开发

### 安装 vbot 组件

```shell
composer require gemini/vbot
```

接下来我们大体讲一下，我对 vbot 组件改造了哪些比较重要的地方，而这块内容，也有助于其他开发者在 Hyperf 框架下使用其他组件时，可能需要做的必要改造。

1. 缓存模块

我们可以看到原先的 vbot 使用的是 Laravel 的缓存模块。

```php
<?php

namespace Hanson\Vbot\Foundation\ServiceProviders;

use Hanson\Vbot\Foundation\ServiceProviderInterface;
use Hanson\Vbot\Foundation\Vbot;
use Illuminate\Cache\CacheManager;
use Illuminate\Cache\MemcachedConnector;
use Illuminate\Filesystem\Filesystem;
use Illuminate\Redis\RedisManager;

class CacheServiceProvider implements ServiceProviderInterface
{
    public function register(Vbot $vbot)
    {
        $vbot['files'] = new Filesystem();

        $vbot->singleton('cache', function ($vbot) {
            return new CacheManager($vbot);
        });
        $vbot->singleton('cache.store', function ($vbot) {
            return $vbot['cache']->driver();
        });
        $vbot->singleton('memcached.connector', function () {
            return new MemcachedConnector();
        });
        $vbot->singleton('redis', function ($vbot) {
            $config = $vbot->config['database.redis'];

            return new RedisManager(array_get($config, 'client', 'predis'), $config);
        });
        $vbot->bind('redis.connection', function ($vbot) {
            return $vbot['redis']->connection();
        });
    }
}
```

所以，我们首先对此模块进行了改造

```php
<?php

declare(strict_types=1);

namespace Hanson\Vbot\Foundation\ServiceProviders;

use Hanson\Vbot\Core\Cache\SimpleCache;
use Hanson\Vbot\Foundation\ServiceProviderInterface;
use Hyperf\Support\Filesystem\Filesystem;
use Pimple\Container;

use function Hyperf\Support\make;

class CacheServiceProvider implements ServiceProviderInterface
{
    public function register(Container $pimple)
    {
        $pimple['files'] = new Filesystem();
        $pimple['cache'] = function () {
            return make(SimpleCache::class);
        };
    }
}

```

因为 vbot 在实际使用 `Illuminate\Cache\CacheManager` 时，也没有使用正常的 psr 规范的 api，所以我们重新实现了一个 `Hanson\Vbot\Core\Cache\SimpleCache`。

```php
<?php

declare(strict_types=1);

namespace Hanson\Vbot\Core\Cache;

use Psr\SimpleCache\CacheInterface;

class SimpleCache
{
    public function __construct(protected CacheInterface $cache)
    {
    }

    public function forget(string $key): void
    {
        $this->cache->delete($key);
    }

    public function has(string $key): bool
    {
        return $this->cache->has($key);
    }

    public function forever(string $key, mixed $data): void
    {
        $this->cache->set($key, $data);
    }

    public function get(string $key): mixed
    {
        return $this->cache->get($key);
    }
}

```

2. 更换配置模块

我们可以看到 `vbot` 模式使用的是 `Illuminate\Config\Repository`，我们直接按照其实现的 API 重新实现了一个配置类。

```php
<?php

declare(strict_types=1);

namespace Hanson\Vbot\Core\Config;

use ArrayAccess;
use Hyperf\Collection\Arr;

class Repository implements ArrayAccess
{
    /**
     * All of the configuration items.
     *
     * @var array
     */
    protected $items = [];

    /**
     * Create a new configuration repository.
     */
    public function __construct(array $items = [])
    {
        $this->items = $items;
    }

    /**
     * Determine if the given configuration value exists.
     *
     * @param string $key
     * @return bool
     */
    public function has($key)
    {
        return Arr::has($this->items, $key);
    }

    /**
     * Get the specified configuration value.
     *
     * @param array|string $key
     * @param mixed $default
     * @return mixed
     */
    public function get($key, $default = null)
    {
        if (is_array($key)) {
            return $this->getMany($key);
        }

        return Arr::get($this->items, $key, $default);
    }

    /**
     * Get many configuration values.
     *
     * @param array $keys
     * @return array
     */
    public function getMany($keys)
    {
        $config = [];

        foreach ($keys as $key => $default) {
            if (is_numeric($key)) {
                [$key, $default] = [$default, null];
            }

            $config[$key] = Arr::get($this->items, $key, $default);
        }

        return $config;
    }

    /**
     * Set a given configuration value.
     *
     * @param array|string $key
     * @param mixed $value
     */
    public function set($key, $value = null)
    {
        $keys = is_array($key) ? $key : [$key => $value];

        foreach ($keys as $key => $value) {
            Arr::set($this->items, $key, $value);
        }
    }

    /**
     * Prepend a value onto an array configuration value.
     *
     * @param string $key
     * @param mixed $value
     */
    public function prepend($key, $value)
    {
        $array = $this->get($key);

        array_unshift($array, $value);

        $this->set($key, $array);
    }

    /**
     * Push a value onto an array configuration value.
     *
     * @param string $key
     * @param mixed $value
     */
    public function push($key, $value)
    {
        $array = $this->get($key);

        $array[] = $value;

        $this->set($key, $array);
    }

    /**
     * Get all of the configuration items for the application.
     *
     * @return array
     */
    public function all()
    {
        return $this->items;
    }

    /**
     * Determine if the given configuration option exists.
     */
    public function offsetExists(mixed $offset): bool
    {
        return $this->has($offset);
    }

    /**
     * Get a configuration option.
     */
    public function offsetGet(mixed $offset): mixed
    {
        return $this->get($offset);
    }

    /**
     * Set a configuration option.
     *
     * @param mixed $value
     */
    public function offsetSet(mixed $offset, $value): void
    {
        $this->set($offset, $value);
    }

    /**
     * Unset a configuration option.
     */
    public function offsetUnset(mixed $offset): void
    {
        $this->set($offset, null);
    }
}

```

然后重写 `private function initializeConfig(array $config)` 方法，进行替换。

3. 替换 Cookies 模块

试想一下，我们已经把缓存放到了 `Redis` 中，一旦我们重启服务容器，所以本地文件都会被清理，所以实际的上下文仍然是丢失的，

那么，我们的缓存就基本失去了效用。

所以，我们将 `Cookies` 数据也一并存到 `Redis` 中。

```php
<?php

declare(strict_types=1);

namespace Hanson\Vbot\Core\Http;

use GuzzleHttp\Cookie\CookieJar;
use GuzzleHttp\Cookie\SetCookie;
use GuzzleHttp\Utils;
use Hanson\Vbot\Foundation\Vbot;
use RuntimeException;

use function is_array;
use function is_scalar;

class CacheCookieJar extends CookieJar
{
    /**
     * Create a new FileCookieJar object.
     *
     * @param bool $storeSessionCookies set to true to store session cookies
     *                                  in the cookie jar
     *
     * @throws RuntimeException if the file cannot be found or created
     */
    public function __construct(private string $key, private Vbot $vbot, private bool $storeSessionCookies = false)
    {
        parent::__construct();

        if ($this->vbot->cache->has($this->key)) {
            $this->load($this->key);
        }
    }

    /**
     * Saves the file when shutting down.
     */
    public function __destruct()
    {
        $this->save($this->key);
    }

    /**
     * Saves the cookies to a file.
     *
     * @throws RuntimeException if the file cannot be found or created
     */
    public function save(string $key): void
    {
        $json = [];
        /** @var SetCookie $cookie */
        foreach ($this as $cookie) {
            if (CookieJar::shouldPersist($cookie, $this->storeSessionCookies)) {
                $json[] = $cookie->toArray();
            }
        }

        $jsonStr = Utils::jsonEncode($json);
        $this->vbot->cache->forever($key, $jsonStr);
    }

    /**
     * Load cookies from a JSON formatted file.
     *
     * Old cookies are kept unless overwritten by newly loaded ones.
     *
     * @throws RuntimeException if the file cannot be loaded
     */
    public function load(string $key): void
    {
        $json = $this->vbot->cache->get($key);
        if (! $json) {
            return;
        }

        $data = Utils::jsonDecode($json, true);
        if (is_array($data)) {
            foreach ($data as $cookie) {
                $this->setCookie(new SetCookie($cookie));
            }
        } elseif (is_scalar($data) && ! empty($data)) {
            throw new RuntimeException("Invalid cookie key: {$key}");
        }
    }
}

```

接下来重写 `HTTP` 模块

```php
<?php

declare(strict_types=1);

namespace Hanson\Vbot\Support;

use Exception;
use GuzzleHttp\Client as HttpClient;
use Hanson\Vbot\Console\Console;
use Hanson\Vbot\Core\Http\CacheCookieJar;
use Hanson\Vbot\Foundation\Vbot;

class Http
{
    public static $instance;

    protected $client;

    protected CacheCookieJar $cookieJar;

    public function __construct(protected Vbot $vbot)
    {
        $this->cookieJar = new CacheCookieJar($vbot->config['cookie_key'], $vbot, true);
        $this->client = new HttpClient(['cookies' => $this->cookieJar]);
    }

    public function get($url, array $options = [])
    {
        return $this->request($url, 'GET', $options);
    }

    public function post($url, $query = [], $array = false)
    {
        $key = is_array($query) ? 'form_params' : 'body';

        $content = $this->request($url, 'POST', [$key => $query]);

        return $array ? json_decode($content, true) : $content;
    }

    public function json($url, $params = [], $array = false, $extra = [])
    {
        $params = array_merge(['json' => $params], $extra);

        $content = $this->request($url, 'POST', $params);

        return $array ? json_decode($content, true) : $content;
    }

    public function setClient(HttpClient $client)
    {
        $this->client = $client;

        return $this;
    }

    /**
     * Return GuzzleHttp\Client instance.
     *
     * @return \GuzzleHttp\Client
     */
    public function getClient()
    {
        return $this->client;
    }

    /**
     * @param string $method
     * @param array $options
     * @param bool $retry
     * @param mixed $url
     *
     * @return string
     */
    public function request($url, $method = 'GET', $options = [], $retry = false)
    {
        try {
            $options = array_merge(['timeout' => 10, 'verify' => false], $options);

            $response = $this->getClient()->request($method, $url, $options);

            $this->cookieJar->save($this->vbot->config['cookie_key']);

            return (string) $response->getBody();
        } catch (Exception $e) {
            $this->vbot->console->log($url . ' ' . $e->getMessage(), Console::ERROR, true);

            if (! $retry) {
                return $this->request($url, $method, $options, true);
            }

            return false;
        }
    }
}

```

4. 最后一步，只需要把所有 Laravel 的组件，替换成 Hyperf 相关组件即可。

### 启动 vbot 模块

1. 我们实现一个监听器，可以在服务启动时，自动开启 vbot 服务

```php
<?php

declare(strict_types=1);

namespace App\Listener;

use Hanson\Vbot\Foundation\Vbot;
use Hyperf\Collection\Collection;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Hyperf\Server\Event\MainCoroutineServerStart;
use Psr\Container\ContainerInterface;
use Throwable;

#[Listener]
class BootVbotListener implements ListenerInterface
{
    public function __construct(protected ContainerInterface $container)
    {
    }

    public function listen(): array
    {
        return [
            MainCoroutineServerStart::class,
        ];
    }

    public function process(object $event): void
    {
        go(function () {
            $pimple = new Vbot([]);
            $pimple->messageHandler->setHandler(fn (Collection $message) => var_dump($message));

            $max = 10;
            while ($max-- > 0) {
                try {
                    $pimple->server->serve();
                } catch (Throwable $exception) {
                    di()->get(StdoutLoggerInterface::class)->error((string) $exception);
                    sleep(10);
                }
            }

            di()->get(StdoutLoggerInterface::class)->error('微信机器人已停止，请重启服务');
        });
    }
}

```

接下来启动服务，我们就可以看到终端处会输出一个二维码，使用我们的微信扫码后，即可登录，然后使用其他微信向这个微信发送一条消息，就可以看到消息被正常输出了。

2. 完善自动回复

```php
<?php

declare(strict_types=1);

namespace App\Service;

use Han\Utils\Service;
use Hanson\Vbot\Message\Text;
use Hyperf\Codec\Json;
use Hyperf\Collection\Collection;
use Hyperf\Logger\LoggerFactory;
use Throwable;

class VbotService extends Service
{
    public function handle(Collection $message): void
    {
        di()->get(LoggerFactory::class)->get('vbot.message')->info(Json::encode($message->toArray()));

        try {
            match ($message->get('type')) {
                Text::TYPE => $this->handleText($message),
                default => null
            };
        } catch (Throwable $exception) {
            $this->logger->error((string) $exception);
        }
    }

    /**
     * 接受到消息.
     */
    public function handleText(Collection $message): void
    {
        $content = trim($message['pure']);
        $isAt = $message['isAt'];
        $fromType = $message['fromType'];
        if (! $isAt || $fromType !== Text::FROM_TYPE_GROUP) {
            return;
        }

        $reply = sprintf('「%s：%s」', $message['sender']['NickName'], $content) . PHP_EOL
            . '- - - - - - - - - - - - - - -' . PHP_EOL
            . '我收到了你的消息';

        Text::send($message['from']['UserName'], $reply);
    }
}

```

### 接入 AI 模块

[Swoole AI](https://chat.swoole.com/#/api)

我们先去 https://business.swoole.com/page/login?invite=11850&from=chatgpt 注册一个账号，然后买一点 `Tokens`，然后生成`秘钥`。

1. 增加配置 `config/autoload/open_api.php`

```php
<?php

declare(strict_types=1);

use function Hyperf\Support\env;

return [
    'default' => [
        'key' => env('OPEN_AI_KEY'),
    ],
];

```

2. 代码实现

这里只做一个简单接口调用。

```php
<?php

declare(strict_types=1);

namespace App\Service;

use GuzzleHttp\Client;
use GuzzleHttp\RequestOptions;
use Han\Utils\Service;
use Hyperf\Codec\Json;
use Hyperf\Config\Annotation\Value;

class OpenAiService extends Service
{
    #[Value(key: 'open_ai.default.key')]
    protected string $key;

    public function client(): Client
    {
        return new Client([
            'base_uri' => 'https://chat.swoole.com',
            'headers' => [
                'Authorization' => "Bearer {$this->key}",
            ],
        ]);
    }

    public function completions(string $content): string
    {
        $res = $this->client()->post('/v1/chat/completions', [
            RequestOptions::JSON => [
                'model' => 'llama2-6b',
                'messages' => [
                    [
                        'role' => 'user', 'content' => $content,
                    ],
                ],
            ],
        ]);

        $result = Json::decode((string) $res->getBody());

        return $result['data']['choices'][1]['message']['content'] ?? '我不知道，别问我';
    }
}

```

3. 接下来修改 vbot 调用方法

> 删除其他无关代码

```php
<?php

declare(strict_types=1);

namespace App\Service;

use Han\Utils\Service;
use Hanson\Vbot\Message\Text;
use Hyperf\Codec\Json;
use Hyperf\Collection\Collection;
use Hyperf\Logger\LoggerFactory;
use Throwable;

class VbotService extends Service
{
    /**
     * 接受到消息.
     */
    public function handleText(Collection $message): void
    {
        $content = trim($message['pure']);
        $isAt = $message['isAt'];
        $fromType = $message['fromType'];
        if (! $isAt || $fromType !== Text::FROM_TYPE_GROUP) {
            return;
        }

        try {
            $result = di()->get(OpenAiService::class)->completions($content);
        } catch (Throwable $exception) {
            $this->logger->error((string) $exception);
            $result = '我不知道，别问我';
        }

        $reply = sprintf('「%s：%s」', $message['sender']['NickName'], $content) . PHP_EOL
            . '- - - - - - - - - - - - - - -' . PHP_EOL
            . $result;

        Text::send($message['from']['UserName'], $reply);
    }
}

```

### 查看最终效果

最后，我们只需要把机器人拉到群里，`@它` 就可以看到最终效果了。

在我测试时，还是发现了一个问题，那就是我启动服务通常都不会手动 `php bin/hyperf.php start`，但当我将服务跑到 容器 里时，二维码便无法正常展示了，所以，这里我们仍需要进行一下改造。

我们打算生成二维码后，上传到 阿里云，这样就可以直接从浏览器里打开二维码，然后进行扫码了。

1. 安装组件

```shell
composer require limingxinleo/aliyun-oss-sdk
composer require limingxinleo/aliyun-php-sdk-core
```

2. 增加配置文件 `config/autoload/oss.php`

```php
<?php

declare(strict_types=1);

use function Hyperf\Support\env;

return [
    'key_id' => env('OSS_KEY_ID'),
    'secret' => env('OSS_SECRET'),
    'bucket' => env('OSS_BUCKET'),
];

```

3. 增加文件上传类

```php
<?php

declare(strict_types=1);

namespace App\Service\SubService;

use Fan\OSS\Client;
use Han\Utils\Service;
use Hyperf\Config\Annotation\Value;
use Psr\Container\ContainerInterface;

class OSSClient extends Service
{
    #[Value(key: 'oss.key_id')]
    protected string $keyId;

    #[Value(key: 'oss.secret')]
    protected string $secret;

    #[Value(key: 'oss.bucket')]
    protected string $bucket;

    protected Client $client;

    public function __construct(ContainerInterface $container)
    {
        parent::__construct($container);

        $this->client = new Client($container, [
            'key' => $this->keyId,
            'secret' => $this->secret,
            'endpoint' => 'https://oss-cn-hangzhou.aliyuncs.com',
        ]);
    }

    public function put(string $path, ?string $object = null): string
    {
        if (! $object) {
            $object = date('Y/m/d') . '/' . uniqid() . '.' . (pathinfo($path)['extension'] ?? 'unknown');
        }

        $fp = fopen($path, 'r+');

        $this->client->uploader->put($this->bucket, $object, $fp, [
            'timeout' => 10,
        ]);

        return sprintf('https://%s.oss-cn-hangzhou.aliyuncs.com/%s', $this->bucket, ltrim($object, '\/'));
    }
}

```

4. 重写二维码实现类

```php
<?php

declare(strict_types=1);

namespace App\Service\SubService;

use Han\Utils\Service;
use Hyperf\Di\Annotation\Inject;
use Hyperf\Support\Filesystem\Filesystem;
use PHPQRCode\QRcode as QrCodeConsole;
use Psr\Container\ContainerInterface;

class VBotQrCode extends Service
{
    #[Inject]
    protected Filesystem $filesystem;

    protected string $path = BASE_PATH . '/runtime/qrcode/';

    public function __construct(ContainerInterface $container)
    {
        parent::__construct($container);

        $this->filesystem->makeDirectory($this->path, 0755, true, true);
    }

    /**
     * show qrCode on console.
     *
     * @param mixed $text
     */
    public function show($text): bool
    {
        QrCodeConsole::png($text, $path = $this->path . uniqid() . '.png');

        $url = di()->get(OSSClient::class)->put($path);

        echo $url . PHP_EOL;

        return true;
    }
}

```

5. 改造我们的 vbot 服务，替换对应的二维码实现类

```php
<?php

declare(strict_types=1);

namespace App\Listener;

use App\Service\SubService\VBotQrCode;
use App\Service\VbotService;
use Hanson\Vbot\Foundation\Vbot;
use Hyperf\Collection\Collection;
use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\Event\Annotation\Listener;
use Hyperf\Event\Contract\ListenerInterface;
use Hyperf\Server\Event\MainCoroutineServerStart;
use Psr\Container\ContainerInterface;
use Throwable;

#[Listener]
class BootVbotListener implements ListenerInterface
{
    public function __construct(protected ContainerInterface $container)
    {
    }

    public function listen(): array
    {
        return [
            MainCoroutineServerStart::class,
        ];
    }

    public function process(object $event): void
    {
        go(function () {
            $pimple = new Vbot([]);
            $pimple['qrCode'] = di()->get(VBotQrCode::class);
            $pimple->messageHandler->setHandler(fn (Collection $message) => di()->get(VbotService::class)->handle($message));

            $max = 10;
            while ($max-- > 0) {
                try {
                    $pimple->server->serve();
                } catch (Throwable $exception) {
                    di()->get(StdoutLoggerInterface::class)->error((string) $exception);
                    sleep(10);
                }
            }

            di()->get(StdoutLoggerInterface::class)->error('微信机器人已停止，请重启服务');
        });
    }
}

```

最后，终于可以愉快的玩耍了。


