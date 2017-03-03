## MAC 下搭建php开发环境

### 安装Homebrew
* 自行查看brew.md

### brew 安装php
~~~
brew tap homebrew/dupes  
brew tap homebrew/versions  
brew tap homebrew/homebrew-php  

brew install php70 --with-homebrew-curl
~~~

### 安装部分扩展
~~~
brew install php70-swoole
brew install php70-redis
brew install php70-phalcon
~~~

### 验证是否正确安装
~~~
php -v
php-fpm -v
~~~

### 配置php-fpm
~~~
vim /usr/local/etc/php/7.0/php-fpm.d/www.conf
修改 user = yourname
修改 group = staff
vim /usr/local/etc/php/7.0/php-fpm.conf
修改 daemonize = yes
~~~

### 安装composer
~~~
brew install composer
~~~

### 找到一个地方作为自己的工作站
~~~
cd ~
mkdir Apps
cd Apps
composer create-project limingxinleo/phalcon-project demo --prefer-dist
cd demo
php run 
~~~
* 当看到以下信息 就代表安装无误了
~~~
Success: The Storage was successfully created. 
~~~

### 安装Nginx
~~~
brew install nginx
sudo nginx
~~~
* 打开浏览器输入127.0.0.1:8080就能看到nginx的欢迎界面了

### 配置Nginx
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

### 修改hosts
~~~
sudo vim /etc/hosts
127.0.0.1 demo.app
~~~

### 查看效果
打开浏览器输入http://demo.app 即可看到效果
