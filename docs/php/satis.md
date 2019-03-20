# 使用 satis 搭建一个私有的 Composer 包仓库
> 在我们的日常php开发中可能需要使用大量的composer包，大部份都可以直接使用，但在公司内部总有一小部份包是不能公开的，这时候我们就需要搭建一个公司内部使用的composer仓库，好在composer官方有提供这样的工具satis和toran proxy,satis搭建相对简单一些，我们今天就选用satis进行。

## 安装
~~~
cd /data/www/
composer create-project composer/satis --stability=dev --keep-vcs
mv satis packages.dev.com
cd packages.dev.com
~~~

## 配置
> satis的配置是通过satis.json进行的，我们在当前目录新建一个satis.json。

~~~
{
    "name": "My Repository",
    "homepage": "http://packages.dev.com",
    "repositories": [
        {"type": "vcs", "url": "http://git.dev.com/maxincai/package1.git"},
        {"type": "vcs", "url": "http://git.dev.com/maxincai/package1.git"},
    ],
    "require": {
        "maxincai/package1": "*",
        "maxincai/package2": "*",
    }
}
~~~
* name：仓库的名字，可以随便定义
* homepage：仓库建立之后的的主页地址
* repositories：指定去哪获取包，url中需要带.git
* require：指定获取哪些包，如果想获取所有包，使用require-all: true,

## 生成
* 使用命令：php bin/satis build .
> 我们生成的时候一般会生成html和paceages.json文件

~~~
php bin/satis build satis.json public/
~~~
> 如果只需要生成某几个包，则可以在后面增加包的名字

~~~
php bin/satis build satis.json web/ this/package that/other-package
~~~
> 使用上面的命令不出意久的会就会在public目录下生成相应的文件，如果出错，根据错误提示去解决即可，常用的问题可能是权限问题，或是git版本过低等。

## 配置服务器 Nginx
> ngin配置

~~~
server {
    listen  80;
    server_name packages.dev.com;
    root /data/www/packages.dev.com/public;
    index index.php index.html;
    access_log /var/log/nginx/packages.dev.com.log main;
    error_log /var/log/nginx/packages.dev.com.log.err debug;
    rewrite_log on;

    location ~* \.php$ {
        #try_files $uri $uri/ /index.php?$query_string;
        #try_files $uri =404;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass  unix:/var/run/php-cgi.sock;
        fastcgi_index index.php;

    }

    location = /favicon.ico {
            log_not_found off;
            access_log off;
    }
}
~~~

## 使用
> 通过上面的配置后，我们就可以在项目中使用了，只需简单的修改composer.json文件

~~~
{
    "repositories": [
      { "type": "composer", "url": "http://packages.dev.com/" }
    ],
    "require": {
        "company/package": "1.2.0",
        "company/package2": "1.5.2",
        "company/package3": "dev-master"
    }
}
~~~

## 下载
> 通过上面的例子你会发现composer update的时候会去我们的git中clone，有时候会比较慢，我们并不希望每次都clone，其实我们也可以缓存在我们的仓库中，这样每次update的时候就只用下载了。

在satis.json中增加
~~~
{
    "archive": {
        "directory": "dist",
        "format": "tar",
        "prefix-url": "http://packages.dev.com/",
        "skip-dev": true
    }
}
~~~
* directory: 必需要的，表示生成的压缩包存放的目录，会在我们build时的目录中
* format: 压缩包格式, zip（默认） tar
* prefix-url: 下载链接的前缀的Url,默认会从homepage中取
* skip-dev: 默认为假，是否跳过开发分支
* absolute-directory: 绝对目录
* whitelist: 白名单，只下载哪些
* blacklist: 黑名单，不下载哪些
* checksum: 可选，是否验证sha1

再次生成
~~~
php bin/satis build satis.json public/
~~~