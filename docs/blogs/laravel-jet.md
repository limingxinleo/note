# 如何解决 Laravel 与 Jet 的冲突

`Laravel` 配合 `Jet` 使用时，因为助手函数 `collect()` 冲突，导致出现以下类型错误

```
xxx must be an instance of Illuminate\Support\Collection, instance of Hyperf\Utils\Collection given
```

## 原因

让我们编写一个接口，测试这个问题

```php
Route::get('/', function () {
    return get_class(collect());
});
```

然后我们可以看到结果是 `Illuminate\Support\Collection`

接下来让我们载入 `Jet` 组件

```shell
composer require hyperf/jet
composer update -o
```

我们便会看到以下报错

> 实际报错可能会因 Laravel 版本不同而发生改变

```
Argument 1 passed to Illuminate\Routing\Router::sortMiddleware() must be an instance of Illuminate\Support\Collection, instance of Hyperf\Utils\Collection given, called in /Users/limingxin/Applications/workspace/php/test/laravel/vendor/laravel/framework/src/Illuminate/Routing/Router.php on line 729
```

我们打开 `vendor/composer/autoload_files.php` 文件，便可以看到以下映射关系

> 以下隐藏其他不相干的文件

```
'bbeb7603826cb9296dde3ca1a840af47' => $vendorDir . '/hyperf/utils/src/Functions.php',
'265b4faa2b3a9766332744949e83bf97' => $vendorDir . '/laravel/framework/src/Illuminate/Collections/helpers.php',
'c7a3c339e7e14b60e06a2d7fcce9476b' => $vendorDir . '/laravel/framework/src/Illuminate/Events/functions.php',
'f0906e6318348a765ffb6eb24e0d0938' => $vendorDir . '/laravel/framework/src/Illuminate/Foundation/helpers.php',
'58571171fd5812e6e447dce228f52f4d' => $vendorDir . '/laravel/framework/src/Illuminate/Support/helpers.php',
```

可见，`Hyperf` 的助手函数会优于 `Laravel` 的助手函数运行，故导致 `collect()` 方法会使用 Hyperf 提供的方法，导致报错。

## 解决

知道这些情况，我们就可以来解决这个问题了

我们可以修改 `Laravel` 的入口函数 `index.php`，在引入 `autoload.php` 之前，优先引入以下四个文件，就可以完美解决这个问题。

```php
require __DIR__ . '/../vendor/laravel/framework/src/Illuminate/Collections/helpers.php';
require __DIR__ . '/../vendor/laravel/framework/src/Illuminate/Events/functions.php';
require __DIR__ . '/../vendor/laravel/framework/src/Illuminate/Foundation/helpers.php';
require __DIR__ . '/../vendor/laravel/framework/src/Illuminate/Support/helpers.php';
require __DIR__ . '/../vendor/autoload.php';
```

因为 `Jet` 组件虽然使用了 `hyperf/utils` 组件，但并没有使用到其中的任何一个助手函数，所以以上修改，不会对 `Jet` 有任何影响。
