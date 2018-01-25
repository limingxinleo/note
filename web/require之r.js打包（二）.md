---
title: requirejs压缩工具r.js打包（二）
date: 2017-09-11 16:16:46
categories: "前端之巅"
tags: '前端'
---

## 单模块打包

至于requirejs大家都是很熟悉的了，它的打包工具r.js是非常好用，也非常强大的，但是建于它的配置参数比较多，这里列出一份所有参数的中文详解，方便理解和记忆。

还有不明白的童鞋可以看看 [require](https://missxiaolin.github.io/2017/03/11/%E5%89%8D%E7%AB%AF/require/)

### 项目地址

[项目地址](https://github.com/missxiaolin/require)

### 先看看目录结构

~~~
   目录
    ├── assets                 
    │   ├── css 
    │   ├── images
    │   ├── font
    │   └── js
    │        └── common 公用插件包
    │        └── index  模块包
    │        └── lib    组件
    ├── index.html  
    ├── app.build.js                   
~~~

### 首页当然是先安装node js

[nodejs](http://nodejs.cn/)

### 安装require js

~~~
npm install -g requirejs
~~~

### app.build.js

~~~
({
    appDir: './assets', // 需要打包的目录
    baseUrl: './js', // js目录
    dir: 'build', // 打包完的目录
    mainConfigFile: './assets/js/lib/config.js', // require.js目录
    name: 'index/index' 需要打包的模块
})
~~~

### 打包r.js命令

~~~
r.js -o app.build.js
~~~

## 多模块打包

~~~
({
    appDir: './assets', // 需要打包的目录
    baseUrl: './js', // js目录
    dir: 'build', // 打包完的目录
    mainConfigFile: './assets/js/lib/config.js', // require.js目录
    "modules": [
    	{
    		name: index
    	},
    	{
    		name: a
    	}
    ]
})
~~~

