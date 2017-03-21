## Homwbrew

### 安装
~~~
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
~~~

### 修改bash_profile文件

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

### 搜索
~~~
brew search php70 phalcon
~~~

### 查询
~~~
brew info php70
~~~

### 更新
~~~
brew update         这会更新 Homebrew 自己，并且使得接下来的两个操作有意义——
~~~

### 检查过时
~~~
brew outdated       这回列出所有安装的软件里可以升级的那些
~~~

### 升级
~~~
brew upgrade php70  升级所有可以升级的软件们
~~~

### 清理
~~~
brew cleanup        清理不需要的版本极其安装包缓存
~~~

### 查看选项
~~~
brew options php70  清理不需要的版本极其安装包缓存
~~~

### 取消&建立关联
~~~
brew list
brew unlink php70
brew link php56
~~~
