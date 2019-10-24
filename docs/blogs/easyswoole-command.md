# EasySwoole 框架接入 HyperfCommand

[仓库地址](https://github.com/Aquarmini/easyswoole-demo)

## 试用 EasySwoole 自定义命令

创建文件

```php
<?php

declare(strict_types=1);

namespace App\Command;

use EasySwoole\EasySwoole\Command\CommandInterface;

class DemoCommand implements CommandInterface
{
    public function commandName(): string
    {
        return 'demo:command';
    }

    public function exec(array $args): ?string
    {
        var_dump('Hello World');

        return 'success';
    }

    public function help(array $args): ?string
    {
        return 'help';
    }
}

```

运行

```php
$ php easyswoole                         
  ______                          _____                              _
 |  ____|                        / ____|                            | |
 | |__      __ _   ___   _   _  | (___   __      __   ___     ___   | |   ___
 |  __|    / _` | / __| | | | |  \___ \  \ \ /\ / /  / _ \   / _ \  | |  / _ \
 | |____  | (_| | \__ \ | |_| |  ____) |  \ V  V /  | (_) | | (_) | | | |  __/
 |______|  \__,_| |___/  \__, | |_____/    \_/\_/    \___/   \___/  |_|  \___|
                          __/ |
                         |___/
Welcome To EASYSWOOLE Command Console!
Usage: php easyswoole [command] [arg]
Get help : php easyswoole help [command]
Current Register Command:
demo:command
help
install
start
stop
reload
phpunit

$ php easyswoole demo:command
string(11) "Hello World"
success
```

> 不得不说，还是相当简洁的。

## 改造

接下来，让我们开始改造一部分代码，给 EasySwoole 插上 Hyperf 的 Command。

EasySwoole 运行模式十分简单，所有的命令都保存在 `CommandContainer` 中，所以我们大可以修改入口文件，把其中的命令全部查出来，动态翻译成 `HyperfCommand`，然后直接运行 `HyperfCommand` 就可以了。

为了不与 `easyswoole` 命令行冲突，我们新建一个 `hyperf` 好了。

首先我们创建一个组件

```
$ composer create hyperf/component-creater hyperf
Installing hyperf/component-creater (v1.1.1)
  - Installing hyperf/component-creater (v1.1.1): Downloading (100%)         
Created project in hyperf
> Installer\Script::install
Setting up optional packages
What is your component name (hyperf/demo): hyperf-cloud/easyswoole-command
What is your component license (MIT) : 
What is your component description : HyperfCommand for EasySwoole
What is your namespace (HyperfCloud\EasyswooleCommand): 
Removing installer development dependencies

  Do you want to use hyperf/framework component ?
  [1] yes
  [n] None of the above
  Make your selection or type a composer package name and version (n): 

  Do you want to use hyperf/di component ?
  [1] yes
  [n] None of the above
  Make your selection or type a composer package name and version (n): 

...

```

并给组件增加 `"hyperf/command": "1.1.*"` 依赖。

下面修改根目录 `composer.json`

```
{
    "require": {
        "easyswoole/easyswoole": "3.x",
        "hyperf-cloud/easyswoole-command": "dev-master"
    },
    "require-dev": {
        "swoft/swoole-ide-helper": "^4.2",
        "friendsofphp/php-cs-fixer": "^2.14",
        "mockery/mockery": "^1.0",
        "phpstan/phpstan": "^0.11.2"
    },
    "autoload": {
        "psr-4": {
            "App\\": "App/"
        }
    },
    "minimum-stability": "dev",
    "prefer-stable": true,
    "config": {
        "sort-packages": true
    },
    "scripts": {
        "test": "co-phpunit -c phpunit.xml --colors=always",
        "cs-fix": "php-cs-fixer fix $1",
        "analyse": "phpstan analyse --memory-limit 300M -l 0 -c phpstan.neon ./App"
    },
    "repositories": {
        "hyperf": {
            "type": "path",
            "url": "./hyperf"
        },
        "packagist": {
            "type": "composer",
            "url": "https://mirrors.aliyun.com/composer"
        }
    }
}

```

### 接管CommandInterface

让我们创建一个 `EasySwooleCommand` 来接管所有的 `CommandInterface`。

```php
<?php

declare(strict_types=1);

namespace HyperfCloud\EasyswooleCommand;

use EasySwoole\EasySwoole\Command\CommandInterface;
use EasySwoole\EasySwoole\Core;
use Hyperf\Command\Command;
use Symfony\Component\Console\Input\InputOption;

class EasySwooleCommand extends Command
{
    /**
     * @var CommandInterface
     */
    protected $command;

    /**
     * @var bool
     */
    protected $coroutine = false;

    public function __construct(CommandInterface $command)
    {
        parent::__construct($command->commandName());
        $this->command = $command;
    }

    public function configure()
    {
        $this->addOption('args', 'a', InputOption::VALUE_IS_ARRAY | InputOption::VALUE_OPTIONAL, 'EasySwoole 入参', []);
    }

    public function handle()
    {
        $args = $this->input->getOption('args');

        if (in_array('produce', $args)) {
            Core::getInstance()->setIsDev(false);
        }
        Core::getInstance()->initialize();

        $result = $this->command->exec($args);

        $this->output->success($result);
    }
}

```

增加 `Application` 初始化所有 `CommandContainer` 中的 `Command`。

```php
<?php

declare(strict_types=1);

namespace HyperfCloud\EasyswooleCommand;

use EasySwoole\Component\Singleton;
use EasySwoole\EasySwoole\Command\CommandContainer;
use Hyperf\Command\Command;
use Hyperf\Contract\ApplicationInterface;
use Symfony\Component\Console\Application as SymfonyApplication;

class Application implements ApplicationInterface
{
    use Singleton;

    protected $commands;

    public function __construct()
    {
        $container = CommandContainer::getInstance();

        $list = $container->getCommandList();

        foreach ($list as $name) {
            $this->commands[] = new EasySwooleCommand($container->get($name));
        }
    }

    public function add(Command $command)
    {
        $this->commands[] = $command;
    }

    public function run()
    {
        $application = new SymfonyApplication();
        foreach ($this->commands as $command) {
            $application->add($command);
        }

        return $application->run();
    }
}

```

最后改造入口函数

```php
<?php

declare(strict_types=1);

use EasySwoole\EasySwoole\Command\CommandRunner;
use HyperfCloud\EasyswooleCommand\Application;

defined('IN_PHAR') or define('IN_PHAR', boolval(\Phar::running(false)));
defined('RUNNING_ROOT') or define('RUNNING_ROOT', realpath(getcwd()));
defined('EASYSWOOLE_ROOT') or define('EASYSWOOLE_ROOT', IN_PHAR ? \Phar::running() : realpath(getcwd()));

$file = EASYSWOOLE_ROOT . '/vendor/autoload.php';
if (file_exists($file)) {
    require $file;
} else {
    die("include composer autoload.php fail\n");
}

// 初始化 CommandContainer
CommandRunner::getInstance();

if (file_exists(EASYSWOOLE_ROOT . '/bootstrap.php')) {
    require_once EASYSWOOLE_ROOT . '/bootstrap.php';
}

Application::getInstance()->run();

```

执行命令 `demo:command`

```
$ php hyperf.php demo:command
string(11) "Hello World"

                                                                                                                        
 [OK] success                                                                                                           
                                                                                                                        

```

启动 `Server`

```
$ php hyperf.php start -a produce
```

### 创建 HyperfCommand

接下来，我们创建一个 `HyperfCommand` 看看效果。

```php
<?php

declare(strict_types=1);

namespace App\Command;

use Hyperf\Command\Command;

class Demo2Command extends Command
{
    public function __construct()
    {
        parent::__construct('demo:command2');
    }

    public function handle()
    {
        var_dump('Hello Hyperf Command.');
    }
}

```

修改 `bootstrap.php`

```php
<?php

declare(strict_types=1);

use EasySwoole\EasySwoole\Command\CommandContainer;
use App\Command\{DemoCommand, Demo2Command};
use HyperfCloud\EasyswooleCommand\Application;

CommandContainer::getInstance()->set(new DemoCommand());
Application::getInstance()->add(new Demo2Command());

```

执行结果

```
$ php hyperf.php demo:command2
string(21) "Hello Hyperf Command."
```

## 写在最后

[Hyperf](https://github.com/hyperf/hyperf) 是基于 Swoole 4.4+ 实现的高性能、高灵活性的 PHP 协程框架，内置协程服务器及大量常用的组件，性能较传统基于 PHP-FPM 的框架有质的提升，提供超高性能的同时，也保持着极其灵活的可扩展性，标准组件均基于 PSR 标准 实现，基于强大的依赖注入设计，保证了绝大部分组件或类都是 可替换 与 可复用 的。

框架组件库除了常见的协程版的 MySQL 客户端、Redis 客户端，还为您准备了协程版的 Eloquent ORM、WebSocket 服务端及客户端、JSON RPC 服务端及客户端、GRPC 服务端及客户端、Zipkin/Jaeger (OpenTracing) 客户端、Guzzle HTTP 客户端、Elasticsearch 客户端、Consul 客户端、ETCD 客户端、AMQP 组件、Apollo 配置中心、阿里云 ACM 应用配置管理、ETCD 配置中心、基于令牌桶算法的限流器、通用连接池、熔断器、Swagger 文档生成、Swoole Tracker、Blade 和 Smarty 视图引擎、Snowflake 全局ID生成器 等组件，省去了自己实现对应协程版本的麻烦。

Hyperf 还提供了 基于 PSR-11 的依赖注入容器、注解、AOP 面向切面编程、基于 PSR-15 的中间件、自定义进程、基于 PSR-14 的事件管理器、Redis/RabbitMQ 消息队列、自动模型缓存、基于 PSR-16 的缓存、Crontab 秒级定时任务、Translation 国际化、Validation 验证器 等非常便捷的功能，满足丰富的技术场景和业务场景，开箱即用。


