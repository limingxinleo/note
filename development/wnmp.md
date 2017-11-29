## Windows Nginx Mysql PHP 环境搭建
### 下载软件
* [PhpStudy](http://www.phpstudy.net/)
* [Sublime](https://www.sublimetext.com/3)
* [PhpStorm](http://www.jetbrains.com/phpstorm/)
* [TortoiseGit](https://tortoisegit.org/)
* [Composer](https://getcomposer.org/Composer-Setup.exe)

### 安装phpStudy
![结果图](http://7xrqhy.com1.z0.glb.clouddn.com/note_phpstydy_run.png)
* 正常情况下，这已经可以正常使用了
* 访问地址 http://127.0.0.1/phpinfo.php

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
* 但是这样实在是不怎么人性化。所以我们把下载的composer.phar复制到之前的php文件夹中，然后在同目录下编写composer.bat
* 添加如下代码
~~~
"%~dp0php.exe" "%~dp0composer.phar" %*
~~~
* cmd 中运行composer 就可以看到效果了
* 因为composer的官方源在国外，国内的情况大家都清楚，所以还是先替换成国内源吧
~~~
composer config repo.packagist composer https://packagist.phpcomposer.com
~~~
* cmd 中安装个项目试试看吧
~~~
composer create-project --prefer-dist laravel/lumen blog
~~~

### Nginx配置
> phpstudy默认是使用apache来做web服务器的，这里主要使用nginx。

* 点击切换版本 使用php7 nginx组合
* 进入Nginx目录，修改conf下的nginx.conf文件，在include vhosts.conf;下增加一行，如下。
~~~
include vhosts.conf;
include conf.d/*.conf;
~~~
* 然后在同目录下增加conf.d文件夹
* 并把[demo.conf](https://github.com/limingxinleo/note/blob/master/nginx/default.conf)复制到conf.d中
* 修改文件 demo.conf
~~~
server_name  demo.app;
root   D:\phpStudy\WWW\lumen\public;

location / {
    if (!-e $request_filename) {
        #rewrite "^/(.*)$" /index.php?_url=/$1 last;
        rewrite "^/(.*)$" /index.php/$1 last;
    }
}
~~~
* 重启服务器
* 修改C:\Windows\System32\drivers\etc\hosts 增加行
~~~
127.0.0.1 demo.app
~~~
* 如果无法修改，复制出来然后修改，再覆盖回去即可
* 访问[http://demo.app](http://demo.app)当你看到如下信息，就表示可以正常使用了
~~~
Lumen (5.3.3) (Laravel Components 5.3.*)
~~~

### 安装TortoiseGit
* 直接安装下载的msi文件
* 扩展全选 安装git-windows

