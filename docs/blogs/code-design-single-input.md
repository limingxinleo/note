# 程序设计之单一入口原则

在我们 `Review` 或者重构代码的时候，或多或少都会有一定的阻力，其中最要紧的便是祖传代码逻辑根本无法理清。 导致牵一发而动全身，`我明明就改了一行代码，怎么整个服务都挂掉了`。

## 正文

接下来，让我们看几段代码，这些都不是一个好的设计。

```php
<?php

class Calculator
{
    public $num;

    public $num2;

    public function getNum()
    {
        return $this->num;
    }

    public function setNum($num): void
    {
        $this->num = $num;
    }

    public function getNum2()
    {
        return $this->num2;
    }

    public function setNum2($num2): void
    {
        $this->num2 = $num2;
    }

    public function add()
    {
        return $this->num + $this->num2;
    }
}

$calculator = new Calculator();
$calculator->setNum(1);
$calculator->setNum2(2);

var_dump($calculator->add());

```

上述代码，乍看是没有任何问题的，但实际上的业务代码会复杂很多，如果我们在 `setNum` 和 `setNum2` 插入了很多逻辑，又或者多次调用了 `setNum` 和 `setNum2`。

那么当你在梳理这段逻辑时，就会变得异常困难，因为你并不知道，哪些位置赋了多少次值，`add()` 又在哪些位置调用了多少次。

比如第一个开发者通过以下代码，想要计算 1+2 的结果。

```php
$calculator = new Calculator();
$calculator->setNum(1);

$this->doSomething($calculator);
$this->doSomething2($calculator);

$calculator->setNum2(2);
$result = $calculator->add();
```

而第二个开发者，可能只是修改了 `doSomething()` 中的逻辑，那么随着迭代次数的增加，很容易会因为 `doSomething()` 中修改了 `$calculator` 的成员变量导致结果出错。

当然，你也可以说既然 `doSomething()` 方法有了依赖关系，不会有人那么蠢，直接修改代码。

如果是有人编写了以下代码

```php
$calculator = new Calculator();
$calculator->setNum(1);

// 保存在上下文中
Context::set('calculator', $calculator);

$this->doSomething();
$this->doSomething2();

$calculator->setNum2(2);
$result = $calculator->add();
```

显而易见，出现BUG的情况，就可能随着迭代次数的增加，呈直线上升趋势。

所以，我们要如何尽可能的避免这个情况呢？

首先，肯定是开发团队严格遵守自己制定的开发规范，严谨修改 `$calculator` 的成员变量，但这很难。

其次便是使用构造函数进行初始化，而非 `setXXX()` 方法。

```php
<?php

class Calculator
{
    protected $num;

    protected $num2;

    public function __construct($num, $num2)
    {
        $this->num = $num;
        $this->num2 = $num2;
    }

    public function add()
    {
        return $this->num + $this->num2;
    }
}
```
