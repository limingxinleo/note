# Homwbrew

## 安装
~~~
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
~~~

## 修改bash_profile文件

> 可以自行谷歌bash_profile等文件的作用

~~~
vim ~/.bash_profile
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
~~~

> 如果使用的是zsh终端

~~~
vim ~/.zshrc
source ~/.bash_profile
~~~

## 搜索
~~~
brew search php70 phalcon
~~~

## 查询
~~~
brew info php70
~~~

## 更新
~~~
brew update         这会更新 Homebrew 自己，并且使得接下来的两个操作有意义——
~~~

## 检查过时
~~~
brew outdated       这回列出所有安装的软件里可以升级的那些
~~~

## 升级
~~~
brew upgrade php70  升级所有可以升级的软件们
~~~

## 清理
~~~
brew cleanup        清理不需要的版本极其安装包缓存
~~~

## 查看选项
~~~
brew options php70  清理不需要的版本极其安装包缓存
~~~

## 取消&建立关联
~~~
brew list
brew unlink php70
brew link php56
~~~

## brew 和 brew cask的区别
* brew
是从下载源码解压然后 ./configure && make install ，同时会包含相关依存库。并自动配置好各种环境变量，而且易于卸载。 
这个对程序员来说简直是福音，简单的指令，就能快速安装和升级本地的各种开发环境。

* brew cask 
已经编译好了的应用包 （.dmg/.pkg），仅仅是下载解压，放在统一的目录中（/opt/homebrew-cask/Caskroom），省掉了自己去下载、解压、拖拽（安装）等蛋疼步骤，同样，卸载相当容易与干净。这个对一般用户来说会比较方便，包含很多在 AppStore 里没有的常用软件。
