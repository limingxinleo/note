# 权限控制

`Hyperf交流群` 里每天都会有各种各样的问题，今天有小伙伴问了一个问题，这里提供一个思路给大家。 

## 有些 PHPer 会有这样的疑问

1. 某些路由必须登录了才能访问，有些路由却不需要登录态。
2. 某些路由在用户登录的情况下，会在原有数据的基础上增加一部分特殊数据。

## 中间件配合协程单例

第一个问题其实很好解决，而大多数同学也一直在这么做，这里再重新整理一下。

首先我们创建一个中间件 `UserMiddleware`，并允许它处理所有的路由。然后我们从 `Headers` 中获取到 `X-Token`，当 `X-Token`不存在时，我们再判断当前的环境是否是开发环境（这里方便自己调试），如果 `X-Token` 存在，则根据 `X-Token` 获取对应的数据。这里使用 `JWT` 来做。

```php
<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Constants\Constants;
use App\Service\Instance\JwtInstance;
use Psr\Container\ContainerInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

class UserMiddleware implements MiddlewareInterface
{
    /**
     * @var ContainerInterface
     */
    protected $container;

    public function __construct(ContainerInterface $container)
    {
        $this->container = $container;
    }

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $token = $request->getHeaderLine(Constants::X_TOKEN);

        if (! empty($token)) {
            JwtInstance::instance()->decode($token);
        } elseif (env('APP_DEBUG', false) === true) {
            JwtInstance::instance()->id = 1;
        }

        return $handler->handle($request);
    }
}

```

接下来我们实现一个简单的 `JwtInstance`，组件使用 `"firebase/php-jwt": "^5.0"`。

```php
<?php

declare(strict_types=1);

namespace App\Service\Instance;

use App\Constants\ErrorCode;
use App\Exception\BusinessException;
use App\Model\User;
use App\Service\Dao\UserDao;
use Firebase\JWT\JWT;
use Hyperf\Utils\Traits\StaticInstance;

class JwtInstance
{
    use StaticInstance;

    const KEY = 'NoteBook';

    /**
     * @var int
     */
    public $id;

    /**
     * @var User
     */
    public $user;

    public function encode(User $user)
    {
        $this->id = $user->id;
        $this->user = $user;

        return JWT::encode(['id' => $user->id], self::KEY);
    }

    public function decode(string $token): self
    {
        try {
            $decoded = (array) JWT::decode($token, self::KEY, ['HS256']);
        } catch (\Throwable $exception) {
            return $this;
        }

        if ($id = $decoded['id'] ?? null) {
            $this->id = $id;
            $this->user = di()->get(UserDao::class)->first($id);
        }

        return $this;
    }

    public function build(): self
    {
        if (empty($this->id)) {
            throw new BusinessException(ErrorCode::TOKEN_INVALID);
        }

        return $this;
    }

    /**
     * @return int
     */
    public function getId(): ?int
    {
        return $this->id;
    }

    /**
     * @return User
     */
    public function getUser(): ?User
    {
        if ($this->user === null && $this->id) {
            $this->user = di()->get(UserDao::class)->first($this->id);
        }
        return $this->user;
    }
}

```

常规的 `decode`，`encode`就不再赘述了，着重讲一下 `build` 和 `getId` 方法，其实很好了解，当我们有路由必须要登录时，我们就在控制器中通过 `build` 获取 `JwtInstance`。

比如我们实现一个 `save` 方法，每当用户保存信息时，都通过以下代码获取 `$userId`，然后再进行保存。这样就有效的实现了 `第一个问题`。

```php
<?php

declare(strict_types=1);

namespace App\Controller;

use App\Request\NoteSearchRequest;
use App\Request\SaveNoteRequest;
use App\Service\Instance\JwtInstance;
use App\Service\NoteService;
use Hyperf\Di\Annotation\Inject;

class NoteController extends Controller
{
    /**
     * @Inject
     * @var NoteService
     */
    protected $service;

    public function save(SaveNoteRequest $request, int $id)
    {
        $text = $request->input('text');

        $userId = JwtInstance::instance()->build()->getId();

        $result = $this->service->save($id, $userId, $text);

        return $this->response->success($result);
    }
}

```

接下来我们查看第二个问题，以下我们实现一个列表方法。然后通过 `getId` 获取当前用户ID，如果用户有登陆态，则在列表中返回用户的 `user_id`。

```php
<?php

declare(strict_types=1);

namespace App\Controller;

use App\Request\NoteSearchRequest;
use App\Request\SaveNoteRequest;
use App\Service\Instance\JwtInstance;
use App\Service\NoteService;
use Hyperf\Di\Annotation\Inject;

class NoteController extends Controller
{
    /**
     * @Inject
     * @var NoteService
     */
    protected $service;

    public function index(NoteSearchRequest $request)
    {
        $offset = (int) $request->input('offset');
        $limit = (int) $request->input('limit');

        $result = $this->service->search($userId, $offset, $limit);

        $userId = JwtInstance::instance()->getId();
        if ($userId) {
            $result['user_id'] = $userId;
        }

        return $this->response->success($result);
    }
}

```



## 注意事项

现在我发现很多同学都喜欢使用 `JWT` 来做 `Token`，但特殊情况下，如果 `Token` 被别人窃取，用户也知道了这件事，但就算他选择登出，也没有任何效果。因为 `Token` 还是能被 `decode` 出有效的信息。所以，这种情况还是推荐在服务端存一下对应的 `Token`，当授权判断时，先验证一下当前 `Token` 是否存在。

## 写在最后

[Hyperf](https://github.com/hyperf-cloud/hyperf)

Hyperf 是基于 `Swoole 4.4+` 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 `PHP-FPM` 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 [PSR 标准](https://www.php-fig.org/psr) 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 `可替换` 与 `可复用` 的。

框架组件库除了常见的协程版的 `MySQL 客户端`、`Redis 客户端`，还为您准备了协程版的 `Eloquent ORM`、`WebSocket 服务端及客户端`、`JSON RPC 服务端及客户端`、`GRPC 服务端及客户端`、`Zipkin/Jaeger (OpenTracing) 客户端`、`Guzzle HTTP 客户端`、`Elasticsearch 客户端`、`Consul 客户端`、`ETCD 客户端`、`AMQP 组件`、`Apollo 配置中心`、`阿里云 ACM 应用配置管理`、`ETCD 配置中心`、`基于令牌桶算法的限流器`、`通用连接池`、`熔断器`、`Swagger 文档生成`、`Swoole Tracker`、`Blade 和 Smarty 视图引擎`、`Snowflake 全局ID生成器` 等组件，省去了自己实现对应协程版本的麻烦。   

Hyperf 还提供了 `基于 PSR-11 的依赖注入容器`、`注解`、`AOP 面向切面编程`、`基于 PSR-15 的中间件`、`自定义进程`、`基于 PSR-14 的事件管理器`、`Redis/RabbitMQ 消息队列`、`自动模型缓存`、`基于 PSR-16 的缓存`、`Crontab 秒级定时任务`、`Translation 国际化`、`Validation 验证器` 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。