# 如何缩小对象体积

有时候，我们会有一种需求，那就是把一个 `对象` 序列化放到队列里，然后消费者取出对象，并处理一定逻辑。但如果对象体积十分庞大，比如一个 `Model`，里面有个字段 `text`，而存储的数据是个极大的富文本。这就导致我们的队列体积过大，造成一定不稳定因素。

所以，接下来，我们来实现一个逻辑，来处理这个问题。

相关 PR [#356](https://github.com/hyperf-cloud/hyperf/pull/356) [#359](https://github.com/hyperf-cloud/hyperf/pull/359)

## 定义 Interface

首先，我们定义 `CodeDegenerateInterface` 和 `CodeGenerateInterface`，他们可以调用对应方法，完成互相转化。

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

namespace Hyperf\Contract;

interface CodeDegenerateInterface
{
    public function degenerate(): CodeGenerateInterface;
}

```

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

namespace Hyperf\Contract;

interface CodeGenerateInterface
{
    public function generate(): CodeDegenerateInterface;
}

```

## 测试 `generate` 和 `degenerate`

首先我们写一个可以互相转化的 `Model` 和 `Meta`

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

namespace HyperfTest\AsyncQueue\Stub;

use Hyperf\Contract\CodeDegenerateInterface;
use Hyperf\Contract\CodeGenerateInterface;
use Hyperf\Utils\Context;

class DemoModel implements CodeGenerateInterface
{
    public $id;

    public $name;

    public $gendar;

    public $signature;

    public function __construct($id, $name, $gendar, $signature)
    {
        $this->id = $id;
        $this->name = $name;
        $this->gendar = $gendar;
        $this->signature = $signature;
    }

    public function generate(): CodeDegenerateInterface
    {
        Context::set('test.async-queue.demo.model.' . $this->id, [
            $this->name, $this->gendar, $this->signature,
        ]);

        return new DemoModelMeta($this->id);
    }
}

```

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

namespace HyperfTest\AsyncQueue\Stub;

use Hyperf\Contract\CodeDegenerateInterface;
use Hyperf\Contract\CodeGenerateInterface;
use Hyperf\Utils\Context;

class DemoModelMeta implements CodeDegenerateInterface
{
    public $id;

    public function __construct($id)
    {
        $this->id = $id;
    }

    public function degenerate(): CodeGenerateInterface
    {
        $data = Context::get('test.async-queue.demo.model.' . $this->id);

        return new DemoModel($this->id, ...$data);
    }
}

```

然后编写对应单元测试

```php
use HyperfTest\AsyncQueue\Stub\DemoModel;
use HyperfTest\AsyncQueue\Stub\DemoModelMeta;

public function testDemoModelGenerate()
{
    $content = Str::random(1000);

    $model = new DemoModel(1, 'Hyperf', 1, $content);
    $s1 = serialize($model);
    $this->assertSame(1128, strlen($s1));

    $meta = $model->generate();
    $s2 = serialize($meta);
    $this->assertSame(65, strlen($s2));
    $this->assertInstanceOf(DemoModelMeta::class, $meta);

    $model2 = $meta->degenerate();
    $this->assertEquals($model, $model2);
}
```

## 改造 AsyncQueue

接下来，我们需要改造 `AsyncQueue`，这里的处理就很简单了，我们在压入队列前，和弹出队列后，分别进行处理。

首先我们改造一下 `Job` 基类。

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

namespace Hyperf\AsyncQueue;

use Hyperf\Contract\CodeDegenerateInterface;
use Hyperf\Contract\CodeGenerateInterface;

abstract class Job implements JobInterface, CodeGenerateInterface, CodeDegenerateInterface
{
    /**
     * @var int
     */
    protected $maxAttempts = 0;

    public function getMaxAttempts(): int
    {
        return $this->maxAttempts;
    }

    /**
     * @return JobInterface
     */
    public function degenerate(): CodeGenerateInterface
    {
        foreach ($this as $key => $value) {
            if ($value instanceof CodeDegenerateInterface) {
                $this->{$key} = $value->degenerate();
            }
        }

        return $this;
    }

    /**
     * @return JobInterface
     */
    public function generate(): CodeDegenerateInterface
    {
        foreach ($this as $key => $value) {
            if ($value instanceof CodeGenerateInterface) {
                $this->{$key} = $value->generate();
            }
        }

        return $this;
    }
}

```

接下来修改我们的 `消息` 类，每当我们序列化时，压缩 `Job`，反序列化时解压缩 `Job` 即可。

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

namespace Hyperf\AsyncQueue;

use Hyperf\Contract\CodeDegenerateInterface;
use Hyperf\Contract\CodeGenerateInterface;
use Serializable;

class Message implements MessageInterface, Serializable
{
    /**
     * @var JobInterface
     */
    protected $job;

    /**
     * @var int
     */
    protected $attempts = 0;

    public function __construct(JobInterface $job)
    {
        $this->job = $job;
    }

    public function job(): JobInterface
    {
        return $this->job;
    }

    public function attempts(): bool
    {
        if ($this->job->getMaxAttempts() > $this->attempts++) {
            return true;
        }
        return false;
    }

    public function serialize()
    {
        if ($this->job instanceof CodeGenerateInterface) {
            $this->job = $this->job->generate();
        }

        return serialize($this->job);
    }

    public function unserialize($serialized)
    {
        $this->job = unserialize($serialized);
        if ($this->job instanceof CodeDegenerateInterface) {
            $this->job = $this->job->degenerate();
        }
    }
}

```

接下来编写单元测试

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

namespace HyperfTest\AsyncQueue\Stub;

use Hyperf\AsyncQueue\Job;

class DemoJob extends Job
{
    public $id;

    public $model;

    public function __construct($id, $model = null)
    {
        $this->id = $id;
        $this->model = $model;
    }

    public function handle()
    {
    }
}

```

```php
use Hyperf\AsyncQueue\Driver\RedisDriver;
use Hyperf\AsyncQueue\Message;
use Hyperf\Utils\Context;
use Hyperf\Utils\Packer\PhpSerializerPacker;
use Hyperf\Utils\Str;
use HyperfTest\AsyncQueue\Stub\DemoJob;
use HyperfTest\AsyncQueue\Stub\DemoModel;
use HyperfTest\AsyncQueue\Stub\DemoModelMeta;
use HyperfTest\AsyncQueue\Stub\Redis;
use Mockery;
use PHPUnit\Framework\TestCase;
use Psr\Container\ContainerInterface;
use Psr\EventDispatcher\EventDispatcherInterface;

public function testAsyncQueueJobGenerate()
{
    $container = $this->getContainer();
    $packer = $container->get(PhpSerializerPacker::class);
    $driver = new RedisDriver($container, [
        'channel' => 'test',
    ]);

    $id = uniqid();
    $content = Str::random(1000);
    $model = new DemoModel(1, 'Hyperf', 1, $content);
    $driver->push(new DemoJob($id, $model));

    $serialized = (string) Context::get('test.async-queue.lpush.value');
    $this->assertSame(218, strlen($serialized));

    /** @var Message $class */
    $class = $packer->unpack($serialized);

    $this->assertSame($id, $class->job()->id);
    $this->assertEquals($model, $class->job()->model);

    $key = Context::get('test.async-queue.lpush.key');
    $this->assertSame('test:waiting', $key);
}

protected function getContainer()
{
    $packer = new PhpSerializerPacker();
    $container = Mockery::mock(ContainerInterface::class);
    $container->shouldReceive('get')->with(PhpSerializerPacker::class)->andReturn($packer);
    $container->shouldReceive('get')->once()->with(EventDispatcherInterface::class)->andReturn(null);
    $container->shouldReceive('get')->once()->with(\Redis::class)->andReturn(new Redis());

    return $container;
}
```

这样，我们的需求就算完成了。