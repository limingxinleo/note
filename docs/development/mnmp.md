# MAC 下搭建php开发环境

## 安装Homebrew
* 自行查看brew.md

## 安装oh my zsh
~~~
brew install zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
vim ~/.zshrc
修改 ZSH_THEME="bira"
~~~

## brew 安装php
~~~ 
brew install php@7.2
~~~

## 验证是否正确安装
~~~
php -v
php-fpm -v
~~~

## 配置php-fpm
~~~
vim /usr/local/etc/php/7.2/php-fpm.d/www.conf
修改 user = yourname
修改 group = staff
vim /usr/local/etc/php/7.2/php-fpm.conf
修改 daemonize = yes
~~~

## 安装composer
~~~
brew install composer
# 切换国内源
composer config -g repo.packagist composer https://packagist.laravel-china.org
~~~

## 找到一个地方作为自己的工作站
~~~
cd ~
mkdir Apps
cd Apps
composer create-project laravel/laravel demo --prefer-dist
~~~

## 安装Nginx
~~~
brew install nginx
sudo nginx
~~~
* 打开浏览器输入127.0.0.1:8080就能看到nginx的欢迎界面了

## 配置Nginx
* 修改nginx.conf
~~~
cd /usr/local/etc/nginx
vim nginx.conf

user limx staff; # user 用户 用户组
~~~

* 增加server配置
~~~
cd /usr/local/etc/nginx/servers
~~~
* 并把[demo.conf](http://7xrqhy.com1.z0.glb.clouddn.com/phalcon.conf)复制到当前文件夹中
* 修改文件 demo.conf
~~~
server_name  demo.app;
root   /Users/yourname/Apps/demo/public;
~~~
* 重启nginx 启动php-fpm
~~~
sudo nginx -s reload
sudo php-fpm
~~~

## 修改hosts
~~~
sudo vim /etc/hosts
127.0.0.1 demo.app
~~~

## 查看效果
打开浏览器输入http://demo.app 即可看到效果

## 编译Swoole示例
~~~
./configure --enable-async-redis --enable-mysqlnd --enable-openssl --enable-http2 --with-openssl-dir=/usr/local/Cellar/openssl@1.1/1.1.1
make
~~~
