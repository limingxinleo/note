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

![](https://user-images.githubusercontent.com/16648551/106448170-5bff8100-64bd-11eb-9f93-c7712e41577f.png)

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
2. 保留原组件命名空间
3. 依赖 `happy-join-hyperf` 组件，方便 `Github` 识别
4. `READMD.md` 中写明白与原组件的区别
5. 保持一个可以持续开源的心态，为自己的组件负责，严禁当 `甩手掌柜`
