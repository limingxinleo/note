# 使用 Micro 打包 PHP 应用

- [lwmbs](https://github.com/dixyes/lwmbs) 巨好用的打包工具，对我来说，Golang的生存空间又被挤掉了一部分。
- [box-skeleton](https://github.com/limingxinleo/box-skeleton) 用于方便构建PHP二进制文件的骨架包。

## 前言

接下来我们使用一个例子，来介绍一下这个东西，平常我更新 Submodule 的时候，都需要进入到对应的文件夹，然后 checkout master 再 pull，着实麻烦。

> 当然，以下的能力，其实也可以写个 shell 脚本代替，但这不是为了介绍一下 micro 打包工具么

## 创建应用

```shell
composer create limingxinleo/box-skeleton sgit dev-master
```

## 创建脚本

首先我们先创建一个脚本

```php
<?php

declare(strict_types=1);
/**
 * This file is part of Hyperf.
 *
 * @link     https://www.hyperf.io
 * @document https://hyperf.wiki
 * @contact  group@hyperf.io
 * @license  https://github.com/hyperf/hyperf/blob/master/LICENSE
 */
namespace App\Command;

use Hyperf\Command\Annotation\Command;
use Hyperf\Command\Command as HyperfCommand;
use Psr\Container\ContainerInterface;
use Symfony\Component\Console\Input\InputOption;

#[Command]
class UpdateCommand extends HyperfCommand
{
    public function __construct(protected ContainerInterface $container)
    {
        parent::__construct('update');
    }

    public function configure()
    {
        parent::configure();
        $this->setDescription('更新子模块');
        $this->addOption('branch', 'B', InputOption::VALUE_OPTIONAL, '需要被更新的分支', 'master');
    }

    public function handle()
    {
        $branch = $this->input->getOption('branch');

        $root = getcwd();
        if (! file_exists($path = $root . '/.gitmodules')) {
            $this->output->writeln($path . ' not found.');
            return;
        }
        $content = file_get_contents($path);
        $preg = '/path = (.*)/';

        $matched = null;
        preg_match_all($preg, $content, $matched);
        $command = 'cd %s && git checkout %s && git pull && cd %s';
        if ($paths = $matched[1] ?? null) {
            foreach ($paths as $path) {
                shell_exec(sprintf($command, $root . '/' . $path, $branch, $root));
            }
        }
    }
}

```

## 打包脚本

1. 首先，我们先打包成 phar

```shell
php bin/hyperf.php phar:build
```

2. 接下来，下载已经可用的 micro

> 这里我使用的是，提前下载好的，大家也可以到 GitHub 上重新下载 https://github.com/dixyes/lwmbs/actions/runs/2722492210

我这里是 x86_64 的 Mac OS，所以提前准备好了 `micro_8.0_x86_64` 版本

```shell
wget https://alpine-apk-repository.knowyourself.cc/micro/v0.0.1/micro.8.0.x86_64.sfx
```

3. 打包

> 打包出来的二进制文件，仅有 41M

```shell
cat micro.8.0.x86_64.sfx sgit.phar > sgit
chmod u+x sgit
mv sgit /usr/local/bin/
```

## 测试

找一个项目，测试下看看

```shell
$ php sgit.phar update
切换到分支 'master'
remote: Enumerating objects: 10, done.
remote: Counting objects: 100% (10/10), done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 6 (delta 4), reused 0 (delta 0), pack-reused 0
展开对象中: 100% (6/6), 841 字节 | 168.00 KiB/s, 完成.
来自 xxxx:xxxx/xxxx
   xxxxx..xxxxx  master     -> origin/master

```

完美运行！！！

