# 如何优雅的打包前端代码

我就是头发掉光，累死，死在ICU，也不会使用 `Docker`。

唉呀妈呀，真香。。。

## Hyperf In Docker

作为 `Hyperf` 框架作者之一，强烈安利大家使用 `Docker`，现在 `Docker集群` 技术已经十分成熟，`K8s` 强势领跑，深受一线企业的厚爱，而`Swarm` 使用简单，绝对是中小型企业的首选。

但今天，并不是讲 `Hyperf` 在 `Docker` 中的应用，而是 `前端` 如何在 `Docker` 中进行打包，并与 `Hyperf` 进行通信。

## 打包

我们下面以 `VUE` 为例。这里提供一个仓库 [vue-docker-demo](https://github.com/Aquarmini/vue-docker-demo)，供大家测试。

首先我们使用 `vue` 脚手架初始化一个项目。

```
vue create vue-docker-demo
```

接下来我们初始化 Hyperf 项目，这里为了方便讲解，后端项目也一同上传到这一个仓库中。

```
cd vue-docker-demo
composer create hyperf/biz-skeleton hyperf
```

### 修改 Hyperf 项目，方便测试

新建 `UserController` 控制器

```php
<?php

declare(strict_types=1);

namespace App\Controller;

class UserController extends Controller
{
    public function info(int $id)
    {
        return $this->response->success([
            'id' => $id,
            'name' => 'Hyperf',
        ]);
    }

    public function update(int $id)
    {
        $name = $this->request->input('name');

        return $this->response->success([
            'id' => $id,
            'name' => $name,
        ]);
    }
}

```

添加路由

```php
<?php

Router::get('/user/{id:\d+}', 'App\Controller\UserController@info');
Router::post('/user/{id:\d+}', 'App\Controller\UserController@update');
```

添加单元测试

```php
<?php

declare(strict_types=1);

namespace HyperfTest\Cases;

use HyperfTest\HttpTestCase;

/**
 * @internal
 * @coversNothing
 */
class UserTest extends HttpTestCase
{
    public function testUserInfo()
    {
        $res = $this->get('/user/1');

        $this->assertSame(0, $res['code']);
        $this->assertSame(['id' => 1, 'name' => 'Hyperf'], $res['data']);
    }

    public function testUserUpdate()
    {
        $res = $this->json('/user/1', [
            'name' => 'limx',
        ]);

        $this->assertSame(0, $res['code']);
        $this->assertSame(['id' => 1, 'name' => 'limx'], $res['data']);
    }
}

```

跑一下接口测试

```
$ composer test
> co-phpunit -c phpunit.xml --colors=always
Detected an available cache, skip the app scan process.
Detected an available cache, skip the vendor scan process.
[DEBUG] Event Hyperf\Framework\Event\BootApplication handled by Hyperf\Di\Listener\BootApplicationListener listener.
[DEBUG] Event Hyperf\Framework\Event\BootApplication handled by Hyperf\Config\Listener\RegisterPropertyHandlerListener listener.
[DEBUG] Event Hyperf\Framework\Event\BootApplication handled by Hyperf\Paginator\Listener\PageResolverListener listener.
PHPUnit 7.5.16 by Sebastian Bergmann and contributors.

...                                                                 3 / 3 (100%)

Time: 309 ms, Memory: 16.00 MB

OK (3 tests, 14 assertions)

```

### 改造 VUE 项目

> 我前端水平有限，所以就写点简单的测试，主要是为了试验 `Dockerfile`。

使用 `NPM` 安装 `axios`

```
npm i axios -S
```

添加 request.js

```
import axios from 'axios'

export default {
    async request(method, url, params) {
        const BASE_URI = '/api';

        return axios({
            method: method,
            url: `${BASE_URI}${url}`,
            data: params,
        });
    }
}
```

修改 `HelloWorld.vue`，以下只展示修改后的部分

```
<script>
    import request from "../api/request";

    export default {
        name: 'HelloWorld',
        messaage: '',
        props: {
            msg: String
        },
        async mounted() {
            var data = await request.request('GET', '/user/1');
            // eslint-disable-next-line no-console
            console.log(data);

            var res = await request.request('POST', '/user/1', { name: "limx" });
            // eslint-disable-next-line no-console
            console.log(res);
        }
    }
</script>
```

### 添加 Dockerfile 和 app.conf

首先，当 `nginx` 拿到 `/api` 前缀后，转发到对应的后端服务，所以这里需要提供一份 `app.conf` 配置

```conf
server {
    listen  80;
    root    /usr/src/app/dist;
    index   index.html;
    client_max_body_size 8M;

    proxy_set_header    Host                $host:$server_port;
    proxy_set_header    X-Real-IP           $remote_addr;
    proxy_set_header    X-Real-PORT         $remote_port;
    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;

    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass  http://biz-skeleton:9501/;
    }
}
```

接下来是我们的 `Dockerfile`，逻辑其实很简单，我们先通过 `node` 环境进行打包，然后再 `copy` 到 `nginx` 环境下即可。

```Dockerfile
FROM node:10-alpine as builder

WORKDIR /usr/src/build

ADD package.json /usr/src/build
ADD package-lock.json /usr/src/build
RUN npm install -g cnpm --registry=https://registry.npm.taobao.org && cnpm install

COPY . /usr/src/build
RUN npm run-script build

FROM nginx:alpine

COPY --from=builder /usr/src/build/dist /usr/src/app/dist
COPY --from=builder /usr/src/build/app.conf /etc/nginx/conf.d/

ENTRYPOINT ["nginx", "-g", "daemon off;"]
```

### 打包测试

首先进入我们 `Hyperf` 目录，打包后端服务

```
cd hyperf
docker build . -t biz-skeleton:latest
```

然后打包我们的前端代码

```
docker build . -t vue-demo
```

创建网关，如果已经创建过，可以忽略这里，并使用创建过的网关

```
$ docker network create \
--subnet 10.0.0.0/24 \
--opt encrypted \
--attachable \
default-network
```

接下来，让我们把两个项目都跑起来

```
docker run -p 9501:9501 --name biz-skeleton --network default-network --rm -d biz-skeleton:latest
docker run -p 8080:80 --name vue-demo --network default-network --rm -d vue-demo:latest
```

然后通过浏览器访问 `http://127.0.0.1:8080/`

就可以看到我们的测试结果在终端中输出了。



## 发布

项目发布这里就不再赘述了，需要了解的就去看一下 `DockerSwarm` 集群搭建，有全自动的打包发布方案，教程就在 `Hyperf` 官方文档中。

这里需要额外提一下的是，打包好的静态文件，每次都走服务器公网流量是很浪费的，这里推荐大家使用 `CDN`，然后配一个回源，可以大大减少流量的压力。当然，回源策略那里要注意一下，把接口返回的数据也缓存到 `CDN` 上就不好了。

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.4+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。