# 组件嗨(Hyperf)化计划

[![Latest Stable Version](https://poser.pugx.org/limingxinleo/happy-join-hyperf/v)](//packagist.org/packages/limingxinleo/happy-join-hyperf)
[![Total Downloads](https://poser.pugx.org/limingxinleo/happy-join-hyperf/downloads)](//packagist.org/packages/limingxinleo/happy-join-hyperf)
[![Latest Unstable Version](https://poser.pugx.org/limingxinleo/happy-join-hyperf/v/unstable)](//packagist.org/packages/limingxinleo/happy-join-hyperf)
[![Dependents](https://poser.pugx.org/limingxinleo/happy-join-hyperf/dependents)](//packagist.org/packages/limingxinleo/happy-join-hyperf)
![Sourcegraph for Repo Reference Count](https://img.shields.io/sourcegraph/rrc/github.com/limingxinleo/happy-join-hyperf)
[![License](https://poser.pugx.org/limingxinleo/happy-join-hyperf/license)](//packagist.org/packages/limingxinleo/happy-join-hyperf)

[happy-join-hyperf](https://github.com/limingxinleo/happy-join-hyperf)

## 介绍

本计划由 `Hyperf` 使用者自行发起并加入，主要为了解决从其他 `PHP框架` 转到 `Hyperf框架` 开发时，核心组件无法被代替，导致需要重写大量代码的问题。

需要嗨化的组件，可以使用以下命令加入此计划

```shell
composer require limingxinleo/happy-join-hyperf --dev
```

当我们将仓库 push 到 Github 之后，就可以被自动识别，如下图所示

![](http://cdn-music.lmx0536.cn/106448170-5bff8100-64bd-11eb-9f93-c7712e41577f.png)

## 第一个嗨化的组件

这里介绍第一个被 Hyperf 化的组件

[illuminate/cache](https://github.com/illuminate/cache)

前不久，群里有小伙伴希望可以为 [hyperf/cache](https://github.com/hyperf/cache) 增加 `tags` 功能，当我第一次听到 `tags` 的时候，完全是懵逼状态，
这是个什么东西？

后来发现，这是 `Laravel` 的一个特性，如果没有使用过的人，完全不知道这个特性的功能。但对于大量使用此功能的 `Laravel` 开发者，迁移项目的时候，这个特性可能就显得额外重要了。
所以，就有了这个可以直接使用 `illuminate/cache` 的需求。而移植组件，对普通开发者而言，或者对于不熟悉 Hyperf 的开发者而言，确实有些困难。

于是，我便花了一上午的时间，将此组件做了移植，并进行开源。

## 嗨化规则

我希望所有嗨化的组件可以尽量遵守以下规则：

1. 保留原组件的 `LICENSE`
2. 尽量保留原组件命名空间
3. 依赖 `happy-join-hyperf` 组件，方便 `Github` 识别
4. `READMD.md` 中写明白与原组件的区别
5. 保持一个可以持续开源的心态，为自己的组件负责，严禁当 `甩手掌柜`

## 关于 Hyperf

Hyperf 是基于 `Swoole 4.5+` 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 `PHP-FPM` 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 [PSR 标准](https://www.php-fig.org/psr) 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 `可替换` 与 `可复用` 的。

框架组件库除了常见的协程版的 `MySQL 客户端`、`Redis 客户端`，还为您准备了协程版的 `Eloquent ORM`、`WebSocket 服务端及客户端`、`JSON RPC 服务端及客户端`、`GRPC 服务端及客户端`、`OpenTracing(Zipkin, Jaeger) 客户端`、`Guzzle HTTP 客户端`、`Elasticsearch 客户端`、`Consul、Nacos 服务中心`、`ETCD 客户端`、`AMQP 组件`、`Nats 组件`、`Apollo、ETCD、Zookeeper、Nacos 和阿里云 ACM 的配置中心`、`基于令牌桶算法的限流器`、`通用连接池`、`熔断器`、`Swagger 文档生成`、`Swoole Tracker`、`Blade、Smarty、Twig、Plates 和 ThinkTemplate 视图引擎`、`Snowflake 全局ID生成器`、`Prometheus 服务监控` 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 `基于 PSR-11 的依赖注入容器`、`注解`、`AOP 面向切面编程`、`基于 PSR-15 的中间件`、`自定义进程`、`基于 PSR-14 的事件管理器`、`Redis/RabbitMQ 消息队列`、`自动模型缓存`、`基于 PSR-16 的缓存`、`Crontab 秒级定时任务`、`Session`、`i18n 国际化`、`Validation 表单验证` 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。
