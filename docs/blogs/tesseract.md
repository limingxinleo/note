# Tesseract 图片识别

[代码仓库](https://github.com/forkgroup/tesseract-demo)
[Hyperf](https://github.com/hyperf-cloud/hyperf)
[tesseract-ocr-for-php](https://github.com/thiagoalessio/tesseract-ocr-for-php)

## 创建项目

```
composer create hyperf/biz-skeleton tesseract-demo
```

## 安装扩展

```
composer require thiagoalessio/tesseract_ocr
```

## 编写接口

### 编写单元测试

首先，我们编写接口单元测试。当没有传 `url` 时，错误码返回 `1000`，当传入图片地址后，返回对应的识别信息。

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

namespace HyperfTest\Cases;

use HyperfTest\HttpTestCase;

/**
 * @internal
 * @coversNothing
 */
class ImageTest extends HttpTestCase
{
    public function testImageReadFailed()
    {
        $res = $this->json('/image/read');
        $this->assertSame(1000, $res['code']);
    }

    public function testImageRead()
    {
        $res = $this->json('/image/read', [
            'url' => 'https://raw.githubusercontent.com/thiagoalessio/tesseract-ocr-for-php/master/tests/EndToEnd/images/8055.png',
        ]);

        $this->assertSame(0, $res['code']);
        $this->assertSame('8055', $res['data']);
    }
}

```

### 添加 Task

因为我们要使用的 `thiagoalessio/tesseract_ocr` 库不确定是否可以进行协程调度，所以我们把具体逻辑放到 [Task](https://doc.hyperf.io/#/zh/task) 中执行。

```
composer require hyperf/task
```

改造我们的 `server.php`

```php
<?php

declare(strict_types=1);

use Hyperf\Server\SwooleEvent;

return [
    // 这里省略了其它不相关的配置项
    'settings' => [
        // Task Worker 数量，根据您的服务器配置而配置适当的数量
        'task_worker_num' => 8,
        // 因为 `Task` 主要处理无法协程化的方法，所以这里推荐设为 `false`，避免协程下出现数据混淆的情况
        'task_enable_coroutine' => false,
    ],
    'callbacks' => [
        // Task callbacks
        SwooleEvent::ON_TASK => [Hyperf\Framework\Bootstrap\TaskCallback::class, 'onTask'],
        SwooleEvent::ON_FINISH => [Hyperf\Framework\Bootstrap\FinishCallback::class, 'onFinish'],
    ],
];
```

### 编写实现逻辑

实现逻辑，非常简单，我们把网图保存到本地，然后通过 `tesseract` 来读取即可。

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

namespace App\Service;

use Hyperf\Guzzle\ClientFactory;
use Hyperf\Task\Annotation\Task;
use thiagoalessio\TesseractOCR\TesseractOCR;

class ImageService
{
    public function read(string $url)
    {
        $path = $this->save($url);

        return $this->tesseract($path);
    }

    /**
     * @Task
     */
    public function tesseract(string $path)
    {
        return (new TesseractOCR($path))->run();
    }

    protected function save(string $url): string
    {
        $client = di()->get(ClientFactory::class)->create();
        $content = $client->get($url)->getBody()->getContents();

        $path = BASE_PATH . '/runtime/' . uniqid();
        file_put_contents($path, $content);

        return $path;
    }
}

```

控制器代码如下

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

use App\Constants\ErrorCode;
use App\Exception\BusinessException;
use App\Service\ImageService;
use Hyperf\Di\Annotation\Inject;
use Hyperf\HttpServer\Annotation\AutoController;

/**
 * @AutoController(prefix="/image")
 */
class ImageController extends Controller
{
    /**
     * @Inject
     * @var ImageService
     */
    protected $service;

    public function read()
    {
        $url = $this->request->input('url');

        if (empty($url)) {
            throw new BusinessException(ErrorCode::PARAMS_INVALID);
        }

        $result = $this->service->read($url);

        return $this->response->success($result);
    }
}

```

### 执行单元测试

```
$ composer test
> co-phpunit -c phpunit.xml --colors=always
Scanning ...
Scan completed.
[DEBUG] Event Hyperf\Framework\Event\BootApplication handled by Hyperf\Di\Listener\BootApplicationListener listener.
[DEBUG] Event Hyperf\Framework\Event\BootApplication handled by Hyperf\Config\Listener\RegisterPropertyHandlerListener listener.
[DEBUG] Event Hyperf\Framework\Event\BootApplication handled by Hyperf\Paginator\Listener\PageResolverListener listener.
PHPUnit 7.5.14 by Sebastian Bergmann and contributors.

...                                                                 3 / 3 (100%)

Time: 1.11 seconds, Memory: 42.00 MB

OK (3 tests, 13 assertions)

```

当然，也可以通过 CURL 访问，查看结果

```
$ curl http://127.0.0.1:9501/image/read -H 'Content-Type:application/json' -d '{"url":"https://raw.githubusercontent.com/thiagoalessio/tesseract-ocr-for-php/master/tests/EndToEnd/images/8055.png"}'
{"code":0,"data":"8055"}%
```

### 修改 Docker

因为默认的 `Docker环境` 没有 `tesseract`，所以我们修改一下 `Dockerfile`

```dockerfile
# Default Dockerfile
#
# @link     https://www.hyperf.io
# @document https://doc.hyperf.io
# @contact  group@hyperf.io
# @license  https://github.com/hyperf-cloud/hyperf/blob/master/LICENSE

FROM hyperf/hyperf:7.2-alpine-cli
LABEL maintainer="Hyperf Developers <group@hyperf.io>" version="1.0" license="MIT"

##
# ---------- env settings ----------
##
# --build-arg timezone=Asia/Shanghai
ARG timezone

ENV TIMEZONE=${timezone:-"Asia/Shanghai"} \
    COMPOSER_VERSION=1.8.6 \
    APP_ENV=prod

# update
RUN set -ex \
    && apk update \
    # 安装 tesseract-ocr
    && apk add tesseract-ocr \
    # install composer
    && cd /tmp \
    && wget https://github.com/composer/composer/releases/download/${COMPOSER_VERSION}/composer.phar \
    && chmod u+x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    # show php version and extensions
    && php -v \
    && php -m \
    #  ---------- some config ----------
    && cd /etc/php7 \
    # - config PHP
    && { \
        echo "upload_max_filesize=100M"; \
        echo "post_max_size=108M"; \
        echo "memory_limit=1024M"; \
        echo "date.timezone=${TIMEZONE}"; \
    } | tee conf.d/99-overrides.ini \
    # - config timezone
    && ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "${TIMEZONE}" > /etc/timezone \
    # ---------- clear works ----------
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && echo -e "\033[42;37m Build Completed :).\033[0m\n"

WORKDIR /opt/www

COPY . /opt/www

RUN composer install --no-dev \
    && composer dump-autoload -o \
    && php /opt/www/bin/hyperf.php di:init-proxy

EXPOSE 9501

ENTRYPOINT ["php", "/opt/www/bin/hyperf.php", "start"]

```

### 构造镜像

```
docker build -t tesseract-demo .
```

### 启动镜像

```
docker run --rm -p 9501:9501 -d --name tesseract-demo tesseract-demo
```

### 测试
```
$ curl http://127.0.0.1:9501/image/read -H 'Content-Type:application/json' -d '{"url":"https://raw.githubusercontent.com/thiagoalessio/tesseract-ocr-for-php/master/tests/EndToEnd/images/8055.png"}'
{"code":0,"data":"8055"}%
```
