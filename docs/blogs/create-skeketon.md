# 创建适合自己的骨架包

有网友每次创建新项目时，都要去执行一次 `composer create-project hyperf/hyperf-skeleton`。其实每次这样创建项目，效率会很低。个人项目其实还好，但是对于公司项目而言，就不是那么友好了。比如有的公司会创建很多组件包，或者很多公共配置之类的代码。每次 `create` 项目都需要重新 `copy` 进来，效率很差，而且又不方便维护。

所以我们可以制作一个骨架包，每次创建新项目，都可以当前骨架包为蓝本进行初始化。

## 制作骨架包

我们使用 `hyperf/hyperf-skeleton` 来创建骨架包，并不安装任何可选项。

```
composer create-project hyperf/hyperf-skeleton parent
```

> 为了方便演示，我使用 `Github` 做版本控制。

将代码上传到 [Aquarmini/skeleton-parent](https://github.com/Aquarmini/skeleton-parent)

```
cd parent
git init
git remote add -m master origin git@github.com:Aquarmini/skeleton-parent.git
git add .
git commit -a -m "INIT"
git push origin master
git branch --set-upstream-to=origin/master master
```

## 创建 Demo 项目

接下来让我们基于 `parent` 创建 `demo` 项目

```
mkdir demo
git init
git remote add -m master parent git@github.com:Aquarmini/skeleton-parent.git
git pull parent master
git branch parent
git branch --set-upstream-to=parent/master parent
git remote add -m master origin git@github.com:Aquarmini/skeleton-demo.git

git checkout master
git push origin master
git push origin master
git branch --set-upstream-to=origin/master master
```

接下来看一下我们的 `git` 配置

```
$ cat .git/config
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
	ignorecase = true
	precomposeunicode = true
[remote "parent"]
	url = git@github.com:Aquarmini/skeleton-parent.git
	fetch = +refs/heads/*:refs/remotes/parent/*
[branch "parent"]
	remote = parent
	merge = refs/heads/master
[remote "origin"]
	url = git@github.com:Aquarmini/skeleton-demo.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
```

让我们随意修改一点代码，并推送到 demo 仓库。

## 合并 Parent 

当我们 parent 有任何修改时，只需要合并进来即可。

比如我们增加一个 `di` 方法，可以方便拿到 `Container`

修改 `composer.json`，以下省略不想关的代码

```json
{
    "autoload": {
        "psr-4": {
            "App\\": "app/"
        },
        "files": [
            "app/Kernel/Functions.php"
        ]
    }
}
```

然后增加 `app/Kernel/Functions.php` 文件

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

use Hyperf\Utils\ApplicationContext;

if (! function_exists('di')) {
    /**
     * Finds an entry of the container by its identifier and returns it.
     * @param null|mixed $id
     * @return mixed|\Psr\Container\ContainerInterface
     */
    function di($id = null)
    {
        $container = ApplicationContext::getContainer();
        if ($id) {
            return $container->get($id);
        }

        return $container;
    }
}

```

提交代码到 parent 项目

然后在 demo 项目中拉取 parent 分支。

```
git checkout parent
git pull parent master
git checkout master
git merge parent
git push origin master
```


## 写在最后

[Hyperf](https://github.com/hyperf-cloud/hyperf)

Hyperf 是基于 `Swoole 4.4+` 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 `PHP-FPM` 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 [PSR 标准](https://www.php-fig.org/psr) 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 `可替换` 与 `可复用` 的。

框架组件库除了常见的协程版的 `MySQL 客户端`、`Redis 客户端`，还为您准备了协程版的 `Eloquent ORM`、`WebSocket 服务端及客户端`、`JSON RPC 服务端及客户端`、`GRPC 服务端及客户端`、`Zipkin/Jaeger (OpenTracing) 客户端`、`Guzzle HTTP 客户端`、`Elasticsearch 客户端`、`Consul 客户端`、`ETCD 客户端`、`AMQP 组件`、`Apollo 配置中心`、`阿里云 ACM 应用配置管理`、`ETCD 配置中心`、`基于令牌桶算法的限流器`、`通用连接池`、`熔断器`、`Swagger 文档生成`、`Swoole Tracker`、`Blade 和 Smarty 视图引擎`、`Snowflake 全局ID生成器` 等组件，省去了自己实现对应协程版本的麻烦。   

Hyperf 还提供了 `基于 PSR-11 的依赖注入容器`、`注解`、`AOP 面向切面编程`、`基于 PSR-15 的中间件`、`自定义进程`、`基于 PSR-14 的事件管理器`、`Redis/RabbitMQ 消息队列`、`自动模型缓存`、`基于 PSR-16 的缓存`、`Crontab 秒级定时任务`、`Translation 国际化`、`Validation 验证器` 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。
