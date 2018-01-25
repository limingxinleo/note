---
title: webpack(一)
date: 2018-01-05 15:16:46
categories: "前端之巅"
tags: '前端'
---

## webpack

由来：

auth：Tobias Koppers (github:@sokra)

GWT(google web Toolkit) -> 代码分隔

作者喜欢这个编辑器的的代码分隔，后面给现有的打包工具pull Request,被拒绝才有了现在的webpack，后面被Instagam维护

### 为什么使用webpack

- vue-cli / React-starter / Angular-cli 都在使用webpack作为构建工具
- Code-splitting 代码分隔
- 模块化开发

## 模块化开发

- js模块化
- css模块化

### js模块化

- 命名空间 （早些年使用）
- commonjs （node.js）
- AMD (require.js)
- CMD
- UMD
- ES6 module

### 命名空间

库名.类别名.方法名

~~~
还可以建立一个注册多级命名空间的机制：
1、命名空间注册工具类     
var Namespace = new Object();     
             
Namespace.register = function(path){     
    var arr = path.split(".");     
    var ns = "";     
    for(var i=0;i<arr.length;i++){     
        if(i>0) ns += ".";     
        ns += arr[i];     
        eval("if(typeof(" + ns + ") == 'undefined') " + ns + " = new Object();");     
    }     
}     
     
2、注册命名空间 com.boohee.ui     
Namespace.register("com.boohee.ui");     
     
3、使用命名空间     
com.boohee.ui.TreeGrid = function(){     
    this.sayHello = function(name){     
        alert("Hello " + name);     
    }     
}     
     
var t = new com.boohee.ui.TreeGrid();     
t.sayHello("uid");
~~~

### commonjs

Modules/1.1.1
一个文件为一个模块
通过 module.exports 暴露模块接口
通过 require 引入模块
同步执行
http://wiki.commonjs.org/wiki/Modules/1.1.1
