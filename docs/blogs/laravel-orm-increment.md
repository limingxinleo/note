# 小心 Laravel 中的 `Model::increment`

Laravel v5.4.18 中的一个提交，导致的 BUG，因为添加了错误的单测，导致没办法轻易修改，这里提醒大家，使用时需要谨慎，以免采坑。

[commit](https://github.com/laravel/framework/commit/ac2d8fc360c8d44ba35bad4182ae5200448cdb5a)

[pr#35748](https://github.com/laravel/framework/pull/35748)

## BUG 重现

- increment extra 后再进行 save 操作，会执行两句SQL

我们先写一段没有 extra 数据的代码，进行测试

```php
DB::enableQueryLog();
$model = UserExt::query()->find(101);
$model->increment('count');
$model->save();
dump(DB::getQueryLog());
```

通过测试得知，以上代码只会生成两段 SQL，分别是

```
select * from `user_ext` where `user_ext`.`id` = ? limit 1
update `user_ext` set `count` = `count` + 1, `user_ext`.`updated_at` = ? where `id` = ?
```

然后让我们修改测试代码

```php
DB::enableQueryLog();
$model = UserExt::query()->find(101);
$model->increment('count', 1, [
    'str' => uniqid()
]);
$model->save();
dump(DB::getQueryLog());
```

这时，会生成以下三段 SQL

```
select * from `user_ext` where `user_ext`.`id` = ? limit 1
update `user_ext` set `count` = `count` + 1, `str` = ?, `user_ext`.`updated_at` = ? where `id` = ?
update `user_ext` set `str` = ?, `user_ext`.`updated_at` = ? where `id` = ?
```

且第二段和第三段 SQL 中，str 的值是一致的。这个问题的主要原因，便是 extra 里的数据不会被同步到 original 中，就导致第二次 save 计算 dirty 的时候，出现了BUG。

- getChanges 表现不一致

经过第一个 BUG 的重现，那么第二个问题也就很容易想到了，就是 getChanges 方法。

让我们继续编写代码测试

```php
$model = UserExt::query()->find(101);
$model->increment('count');
dump($model->getChanges());
```

以上代码会输出以下数据，可见还是符合预期的

```
array:1 [▼
  "count" => 4
]
```

让我们继续修改代码，在 `increment` 前增加一次赋值

```php
DB::enableQueryLog();
$model = UserExt::query()->find(101);
$model->str = uniqid();
$model->increment('count');
dump($model->getChanges());
dump(DB::getQueryLog());
```

会得到以下输出

```
array:2 [▼
  "count" => 7
  "str" => "5febf2dc798ed"
]
```

看似没有问题，但让我们检查一下 SQL

```
select * from `user_ext` where `user_ext`.`id` = ? limit 1
update `user_ext` set `count` = `count` + 1, `user_ext`.`updated_at` = ? where `id` = ?
```

却发现，并没有修改 str 的数据，那显然 getChanges 与预期不符。

实际上，increment 在设计上，并没有想要修改前面 setter 的数据，但这种情况下，我们 getChanges 便也不能把 str 算进来。

让我们继续修改代码

```php
DB::enableQueryLog();
$model = UserExt::query()->find(101);
$model->str = uniqid();
$model->increment('count');
dump($model->getChanges());
$model->save();
dump($model->getChanges());
dump(DB::getQueryLog());
```

两次 getChanges 输出如下

```
array:2 [▼
  "count" => 9
  "str" => "5febf3d6418e8"
]
array:2 [▼
  "str" => "5febf3d6418e8"
  "updated_at" => "2020-12-30 03:28:22"
]
```

> save 的时候会把 updated_at 算进来，而 `increment` 的时候是不会算 `updated_at`，这里至少行为一致，可以作为后续的优化项。

输出的 SQL 如下

```
select * from `user_ext` where `user_ext`.`id` = ? limit 1
update `user_ext` set `count` = `count` + 1, `str` = ?, `user_ext`.`updated_at` = ? where `id` = ?
update `user_ext` set `str` = ?, `user_ext`.`updated_at` = ? where `id` = ?
```

