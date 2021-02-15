# 如何在 Hyperf 框架中使用门面

## 组件嗨化计划

本计划由 `Hyperf` 使用者自行发起并加入，主要为了解决从其他 `PHP框架` 转到 `Hyperf框架` 开发时，核心组件无法被代替，导致需要重写大量代码的问题。

需要嗨化的组件，可以使用以下命令加入此计划

```shell
composer require limingxinleo/happy-join-hyperf --dev
```

## 正文

`Facade` 是一种很简单的静态代理，因为使用人数偏多，便提供了一个简单的门面实现，可以方便开发者由 Laravel 框架迁移到 Hyperf 框架中。 

### 安装组件

```
composer require limingxinleo/hyperf-facade
```

### 使用

我们可以直接使用对应的门面类

```php
<?php

use HFacade\Config;

Config::get('xxx');
```

当配置 `BootListener` 到 `listeners.php` 后

```php
<?php
use HFacade\Listener\BootListener;

return [
    BootListener::class
];
```

我们便可以不带命名空间使用门面

```php
<?php

Config::get('app');
```