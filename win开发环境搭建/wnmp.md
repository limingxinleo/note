## Windows Nginx Mysql PHP 环境搭建
### 下载软件
* [PhpStudy](http://www.phpstudy.net/)
* [Sublime](https://www.sublimetext.com/3)
* [PhpStorm](http://www.jetbrains.com/phpstorm/)
* [TortoiseGit](https://tortoisegit.org/)
* [Composer](https://getcomposer.org/Composer-Setup.exe)

### 安装phpStudy
![结果图](http://7xrqhy.com1.z0.glb.clouddn.com/note_phpstydy_run.png)
> 正常情况下，这已经可以正常使用了
> 访问地址 http://127.0.0.1/phpinfo.php

### 小DEMO
* 打开cmd终端 输入php -v
* 因为没有把php加入环境变量 所以会报以下错误

![php没有加入环境变量](http://7xrqhy.com1.z0.glb.clouddn.com/note_no_php_envirement.png)

* 进入php文件夹 

![php存储位置](http://7xrqhy.com1.z0.glb.clouddn.com/note_php_path.png)

* 我的php文件夹目录为 D:\phpStudy\php\php-7.0.12-nts
* 编辑目录下的php.ini
~~~
;extension=php_openssl.dll
改为
extension=php_openssl.dll
~~~

![修改环境变量](http://7xrqhy.com1.z0.glb.clouddn.com/note_path.png)

* 重开cmd 运行php -v 可能会出现下面错误

![错误1](http://7xrqhy.com1.z0.glb.clouddn.com/note_error_1.png)

* 访问 http://www.phpstudy.net/a.php/184.html 解决
* 下载并安装vc9 vc11 vc14 运行库

~~~
php -v

PHP 7.0.12 (cli) (built: Oct 13 2016 11:04:07) ( NTS )
Copyright (c) 1997-2016 The PHP Group
Zend Engine v3.0.0, Copyright (c) 1998-2016 Zend Technologies
~~~

* 新建一个php文件 输入如下代码

~~~
<?php
echo "HELLO WORLD";
~~~

* 重新进入cmd
* 运行 php /your/path/to/test.php

### 安装composer
* composer 作为包管理器，要是不会用，就不要写php了
* 安装之前下载的composer.exe
* 如果安装不上 那就直接到https://getcomposer.org/download/ 中下载[composer.phar](https://getcomposer.org/download/1.3.1/composer.phar)文件
* 如果还下载不下来 那就安装我上传的[composer](http://7xrqhy.com1.z0.glb.clouddn.com/composer.phar)好了

#### 编写composer.bat
* 如果直接下载了composer.phar文件是没办法直接运行的，除非使用php composer.phar
* 但是这样实在是不怎么人性化。所以我们把下载的composer.phar复制到之前的php文件夹中，然后再统计目录编写composer.bat
~~~
"%~dp0php.exe" "%~dp0composer.phar" %*
~~~
* cmd 中运行composer 就可以看到效果了

### 安装TortoiseGit
* 直接安装下载的msi文件
* 扩展全选 安装git-windows

