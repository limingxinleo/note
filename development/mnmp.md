## MAC 下搭建php开发环境

### 安装Homebrew
* 自行查看brew.md

### brew 安装php
~~~
brew tap homebrew/dupes  
brew tap homebrew/versions  
brew tap homebrew/homebrew-php  

brew install php70
brew install php70-devel
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
phpf-pm -v
~~~
