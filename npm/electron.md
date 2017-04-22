## electron

### 安装Electron的时候，往往卡在了node install.js这一步
~~~
$ node install.js
~~~

这句命令的install.js是electron这个包里的，里面的下载是依赖于electron-download这个模块。
在github上面，electron-download这个包里有如下标注：
~~~
You can set the ELECTRON_MIRROR or NPM_CONFIG_ELECTRON_MIRROR environment variable or mirror opt variable to use a custom base URL for grabbing Electron zips. The same pattern applies to ELECTRON_CUSTOM_DIR and ELECTRON_CUSTOM_FILENAME:

## Electron Mirror of China
ELECTRON_MIRROR="https://npm.taobao.org/mirrors/electron/"
## or for a local mirror
ELECTRON_MIRROR="https://10.1.2.105/"
ELECTRON_CUSTOM_DIR="our/internal/filePath"
You can set ELECTRON_MIRROR in .npmrc as well, using the lowercase name:

electron_mirror=https://10.1.2.105/
~~~

所以解决的方法就是在~/.npmrc里做如下设置:
~~~
electron_mirror="https://npm.taobao.org/mirrors/electron/"
~~~
