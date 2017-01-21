### 国内镜像
× 编辑~/.npmrc
~~~
registry = https://registry.npm.taobao.org
~~~

### npm的镜像源管理工具
>npm install -g nrm

* 命令：nrm ls 用于展示所有可切换的镜像地址
* 命令：nrm use cnpm 我们这样就可以直接切换到cnpm上了。当然也可以按照上面罗列的其他内容进行切换。

### 使用webpack
* 安装
~~~
// 全局安装
npm install -g webpack
// 安装到当前目录项目
npm install webpack
~~~

* 初始化项目
~~~
npm init
npm install --save-dev webpack
~~~

* 编写webpack.config.js
~~~
module.exports = {
  entry:  __dirname + "/app/main.js",//已多次提及的唯一入口文件
  output: {
    path: __dirname + "/public",//打包后的文件存放的地方
    filename: "bundle.js"//打包后输出文件的文件名
  }
}
~~~

* 打包
~~~
webpack
~~~

