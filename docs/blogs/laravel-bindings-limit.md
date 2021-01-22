# Laravel Bindings 的一处安全隐患

相关 PR 如下

[#35865](https://github.com/laravel/framework/pull/35865)
[#35972](https://github.com/laravel/framework/pull/35972)

> 以下的代码使用 8.x 的代码测试，这个问题 `6.x` 与 `7.x` 版本同样存在

## 原因

我们先看一下未修改前的代码表现，我们使用 `laravel/framework` 组件的 `8.22.0` 版本进行实现。

表结构如下

```
CREATE TABLE `test` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL DEFAULT '0',
  `type` int(10) unsigned NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

如果我们对入参都检测的很清楚，比如以下情况

```
Route::get('/', function () {
    DB::enableQueryLog();
    $data = Test::query()->where('uid', 1)->where('type', 0)->get();
    var_dump(count($data));
    var_dump(DB::getQueryLog());
    return 'Hello World.';
});
```

显然结果是符合预期的

```
int(1)
array(1) {
  [0]=>
  array(3) {
    ["query"]=>
    string(51) "select * from `test` where `uid` = ? and `type` = ?"
    ["bindings"]=>
    array(2) {
      [0]=>
      int(1)
      [1]=>
      int(0)
    }
    ["time"]=>
    float(10.07)
  }
}
Hello World.
```

但，如果我们的 `uid` 是通过接口传入进来，但又没有对其进行检测，那么就会导致 `uid` 可能传入一个数组。

```
Route::get('/', function () {
    try {
        DB::enableQueryLog();
        $data = Test::query()->where('uid', [1, 1])->where('type', 0)->get();
        var_dump(count($data));
        var_dump(DB::getQueryLog());
        return 'Hello World.';
    } catch (\Throwable $exception) {
        return 'Server Error';
    }
});
```

那么结果就会天差地别

```
int(2)
array(1) {
  [0]=>
  array(3) {
    ["query"]=>
    string(51) "select * from `test` where `uid` = ? and `type` = ?"
    ["bindings"]=>
    array(3) {
      [0]=>
      int(1)
      [1]=>
      int(1)
      [2]=>
      int(0)
    }
    ["time"]=>
    float(9.24)
  }
}
Hello World.
```

第一个查询的 SQL 是 select * from `test` where `uid` = 1 and `type` = 0
而后来的查询却是 select * from `test` where `uid` = 1 and `type` = 0

当然，你可能认为这并没有什么，但如果你的 `SQL` 是更新操作呢，又如果你的 `user_id` 不幸放到了后面呢？那岂不是所有的用户都可以改改自己的接口入参，修改到别人的数据？

## Laravel 的修改

接下来，让我们看一下 `Laravel` 的修改办法，其实核心就是一个，那就是如果发现入参是 `Array`，就主动使用 `head` 方法取 `Array` 的第一个元素。

让我们更新 `laravel/framework` 组件到 `8.24.0` 再看。

```
int(1)
array(1) {
  [0]=>
  array(3) {
    ["query"]=>
    string(51) "select * from `test` where `uid` = ? and `type` = ?"
    ["bindings"]=>
    array(2) {
      [0]=>
      int(1)
      [1]=>
      int(0)
    }
    ["time"]=>
    float(11.33)
  }
}
Hello World.
```

从结果上看，确实似乎解决了上面的问题，但实则引入了一个更加严重的隐患，将安全隐患变成了事故隐患。

### 可能存在的事故隐患

以下代码都是基于这次修改，我本人是不会这么写代码的

首先，我们假定，开发者已经知道了上述问题，而且他认为上述情况也是合理的，也是这么用的。

那么 Laravel 的这次修改，并不会报任何错，但代码含义却完全不同，本来用户就想修改 type=1, user_id=1 的记录，一旦框架去掉了后面的数据，那搞不好就修改成了 type=1, user_id=0 的记录。

如果 user_id = 0 代表的含义是没有用户ID的记录，岂不是一口气将所有非用户产生的消息全部修改掉。。

## 结论

所以，我认为还是应该直接抛出错误

```
    /**
     * Get a scalar type value from an unknown type of input.
     *
     * @param  mixed  $value
     * @return mixed
     */
    protected function flattenValue($value)
    {
        if(is_array($value)){
            throw new \InvalidArgumentException();
        }

        return $value;
    }
```

那么刚刚的代码就会出现以下情况

```
Server Error
```





