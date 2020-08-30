# Laravel里的那些坑-Optional

[Github仓库](https://github.com/Aquarmini/bugs-laravel-optional)

## 什么是 Optional

先让我们看一段 `NodeJS` 的代码

```js
var obj = null;

console.log(obj?.id);
```

上述代码会输出 `undefined`，如果去掉中间的 `?`，则会抛出一个 `TypeError`

```
console.log(obj.id);
                ^

TypeError: Cannot read property 'id' of null
```

而 `Optional` 就是 `PHP` 中的一个封装

## Laravel 中的实现

我们可以直接在 `Laravel` 框架中执行以下代码

```php
<?php
dump(optional(null)->id);
```

会输出 `null`

但当我们仔细看一下源码，其实实现是有坑的，按照正常的设计我们编写以下代码进行测试

```php
$obj = (object)['id' => 1];
dump(isset(optional($obj)->id)); // true
dump(optional($obj)->id); // 1
dump(isset(optional($obj)['id'])); // false
dump(optional($obj)['id']); // false

$obj = ['id' => 1];
dump(isset(optional($obj)->id)); // true
dump(optional($obj)->id); // null
dump(isset(optional($obj)['id'])); // true
dump(optional($obj)['id']); // 1
```

我们会发现当入参是数组的时候，我判断当前是否存在 `id`，结果是存在，但去拿值的时候，却是 `null`

然后让我们看一下源码，以下只展示相关的代码片段。

```php
<?php

namespace Illuminate\Support;

use ArrayAccess;
use ArrayObject;

class Optional implements ArrayAccess
{
    /**
     * Dynamically access a property on the underlying object.
     *
     * @param  string  $key
     * @return mixed
     */
    public function __get($key)
    {
        if (is_object($this->value)) {
            return $this->value->{$key} ?? null;
        }
    }

    /**
     * Dynamically check a property exists on the underlying object.
     *
     * @param  mixed  $name
     * @return bool
     */
    public function __isset($name)
    {
        if (is_object($this->value)) {
            return isset($this->value->{$name});
        }

        if (is_array($this->value) || $this->value instanceof ArrayObject) {
            return isset($this->value[$name]);
        }

        return false;
    }
}

```

可见，在判断是否存在成员变量和获取成员变量的逻辑完全不一致。这才导致了这个问题。

这段代码，是后来其他人提交上去的 PR，所以我猜测，一开始的设计是，object 是 object ，array 是 array。二者是不能混用的，所以下面这段代码其实不应该被添加进来。

```php
if (is_array($this->value) || $this->value instanceof ArrayObject) {
    return isset($this->value[$name]);
}
```

而在官方的单元测试中，`__isset` 的单测对 `array` 的情况已经覆盖到了，而 `__get` 也是一样，这就导致无论是删除这段代码，还是添加这段代码到 `__get` 上，都会导致框架 `BC`。

> 相关 [PR](https://github.com/laravel/framework/pull/33971)

所以只能希望 `Laravel 8.0` 会修改这个问题了。

## Hyperf 中的实现

Hyperf 框架对这么好用的东西已经做了移植，并解决了这个问题。

我们在 Hyperf 框架中编写以下测试

```php
$obj = (object)['id' => 1];
dump(isset(optional($obj)->id));
dump(optional($obj)->id);
dump(isset(optional($obj)['id']));
dump(optional($obj)['id']);

$obj = ['id' => 1];
dump(isset(optional($obj)->id));
dump(optional($obj)->id);
dump(isset(optional($obj)['id']));
dump(optional($obj)['id']);
```

可以看到输出是和我们的预想一致的

```
true
1
false
null
false
null
true
1
```

