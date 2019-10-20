# 登录模块

`Uniapp` 支持打包成各种小程序，但我们暂时只支持 微信小程序，所以代码设计中，暂不考虑其他情况。

## 创建用户表

```SQL
CREATE TABLE `users` (
  `id` bigint(11) unsigned NOT NULL AUTO_INCREMENT,
  `nickname` varchar(256) NOT NULL DEFAULT '' COMMENT '昵称',
  `avatar` varchar(256) NOT NULL DEFAULT '' COMMENT '头像',
  `gender` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '1男',
  `openid` varchar(64) NOT NULL DEFAULT '' COMMENT 'OPENID',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQUE_OPENID` (`openid`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

## 创建模型

```php
<?php

declare (strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://doc.hyperf.io
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE
 */
namespace App\Model;

/**
 * @property int $id
 * @property string $nickname
 * @property string $avatar
 * @property int $gender
 * @property string $openid
 * @property \Carbon\Carbon $created_at
 * @property \Carbon\Carbon $updated_at
 */
class User extends Model
{
    /**
     * The table associated with the model.
     *
     * @var string
     */
    protected $table = 'users';
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = ['id', 'nickname', 'avatar', 'gender', 'openid', 'created_at', 'updated_at'];
    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = ['id' => 'integer', 'gender' => 'integer', 'created_at' => 'datetime', 'updated_at' => 'datetime'];
}
```

## 登录流程

![](../imgs/NoteBookLogin.jpg)

## 用户注册

### 增加对应路由

config.php

```
Router::post('/regist', 'App\Controller\UserController@regist');
```

### 实现微信登录

因为 `EasyWeChat` 的设计还是以 `FPM` 为基础的，所以我们不能直接将 `$app` 存在内存中。  

```php
<?php

declare(strict_types=1);

namespace App\Kernel\Oauth;

use EasyWeChat\Factory;
use GuzzleHttp\Client;
use GuzzleHttp\HandlerStack;
use Hyperf\Contract\ConfigInterface;
use Hyperf\Guzzle\CoroutineHandler;
use Hyperf\Guzzle\HandlerStackFactory;
use Overtrue\Socialite\Providers\AbstractProvider;
use Psr\Container\ContainerInterface;

class WeChatFactory
{
    /**
     * @var ContainerInterface
     */
    protected $container;

    public function __construct(ContainerInterface $container)
    {
        $this->container = $container;
        $this->config = $container->get(ConfigInterface::class)->get('oauth.wechat');

        // 设置 OAuth 授权的 Guzzle 配置
        AbstractProvider::setGuzzleOptions([
            'http_errors' => false,
            'handler' => HandlerStack::create(new CoroutineHandler()),
        ]);
    }

    /**
     * @return \EasyWeChat\MiniProgram\Application
     */
    public function create()
    {
        $app = Factory::miniProgram($this->config);

        // 设置 HttpClient，当前设置没有实际效果，在数据请求时会被 guzzle_handler 覆盖，但不保证 EasyWeChat 后面会修改这里。
        $config = $app['config']->get('http', []);
        $config['handler'] = $this->container->get(HandlerStackFactory::class)->create();
        $app->rebind('http_client', new Client($config));

        // 重写 Handler
        $app['guzzle_handler'] = $this->container->get(HandlerStackFactory::class)->create();

        return $app;
    }
}

```

### 完善注册

前端登录后把获得的 `code`,`encrypted_data` 和 `iv` 传上来，后端进行解密，并保存用户。

```php
<?php

declare(strict_types=1);

namespace App\Controller;

use App\Request\LoginRequest;
use App\Request\RegistRequest;
use App\Service\Formatter\UserFormatter;
use App\Service\UserService;
use Hyperf\Di\Annotation\Inject;

class UserController extends Controller
{
    public function regist(RegistRequest $request)
    {
        $code = (string) $request->input('code');
        $encryptedData = (string) $request->input('encrypted_data');
        $iv = (string) $request->input('iv');

        [$token, $user] = $this->service->regist($code, $encryptedData, $iv);

        return $this->response->success([
            'token' => $token,
            'user' => UserFormatter::instance()->base($user),
        ]);
    }
}

```

以下 `UserDao` 的使用，只是一个数据库操作的封装，这里不做介绍。

```php
<?php

declare(strict_types=1);

namespace App\Service;

use App\Constants\ErrorCode;
use App\Exception\BusinessException;
use App\Kernel\Oauth\WeChatFactory;
use App\Service\Dao\UserDao;
use App\Service\Instance\JwtInstance;
use App\Service\Redis\UserCollection;
use Hyperf\Di\Annotation\Inject;

class UserService extends Service
{
    /**
     * @Inject
     * @var WeChatFactory
     */
    protected $factory;

    /**
     * @Inject
     * @var UserDao
     */
    protected $dao;

    public function regist($code, $encrypted_data, $iv)
    {
        $app = $this->factory->create();

        $session = $app->auth->session($code);

        $userInfo = $app->encryptor->decryptData($session['session_key'], $iv, $encrypted_data);

        $user = $this->dao->create($userInfo);

        $token = JwtInstance::instance()->encode($user);

        return [$token, $user];
    }
}

```

另外这里 `Token` 的存取直接使用 `Jwt` 来做，但真正开发时，就算使用 `Jwt` 来做授权，也要在后端验证 `Token` 是否存在等逻辑，比如用户 `Jwt Token` 被窃取，登出系统后，也可使 `Token` 作废，及时止损。

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