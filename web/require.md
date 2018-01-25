---
title: require
date: 2017-03-11 15:16:46
categories: "前端之巅"
tags: '前端'
---

### 原始写法

~~~
function m1(){
	//...
}
function m2(){
　	//...
}
使用：
m1();
缺点：
1."污染"了全局变量，无法保证不与其他模块发生变量名冲突。
2.而且模块成员之间看不出直接关系。
~~~

### 对象的写法

~~~
var module1 = new Object({
　　　　_count : 0,
　　　　m1 : function (){
　　　　　　//...
　　　　},
　　　　m2 : function (){
　　　　　　//...
　　　　}
});
使用：
module1.m1();
缺点：
1.内部属性可以被外部改写，不安全。
~~~

### 立即执行函数写法

~~~
var module1 = (function(){
　　　　var _count = 0;
　　　　var m1 = function(){
　　　　　　//...
　　　　};
　　　　var m2 = function(){
　　　　　　//...
　　　　};
　　　　return {
　　　　　　m1 : m1,
　　　　　　m2 : m2
　　　　};
　　})();
使用：
module1.m1();
优点：
1.外部代码无法读取内部的_count变量
console.log(module1._count); //undefined
2.只有return了的才能在外部调用
module1.m1();
module1就是Javascript模块的基本写法。
~~~

### 输入全局变量

~~~
独立性是模块的重要特点，模块内部最好不与程序的其他部分直接交互。
为了在模块内部调用全局变量，必须显式地将其他变量输入模块。

　var module1 = (function ($, YAHOO) {
　　　　//...
　　})(jQuery, YAHOO);

使用：
module1.m();
上面的module1模块需要使用jQuery库和YUI库，就把这两个库（其实是两个模块）当作参数输入module1。这样做除了保证模块的独立性，还使得模块之间的依赖关系变得明显。
~~~

### 模块的规范

- 有了模块，我们就可以更方便地使用别人的代码，想要什么功能，就加载什么模块。但是，这样做有一个前提，那就是大家必须以同样的方式编写模块，否则你有你的写法，我有我的写法，岂不是乱了套！考虑到Javascript模块现在还没有官方规范，这一点就更重要了。
	
### CommonJS

~~~
node.js的模块系统，就是参照CommonJS规范实现的。
在CommonJS中，有一个全局性方法require()，用于加载模块。假定有一个数学模块math.js，就可以像下面这样加载。
　　var math = require('math');
然后，就可以调用模块提供的方法：
　　var math = require('math');
　　math.add(2,3); // 5
因为我们是主要针对浏览器编程，不涉及node.js，所以对CommonJS就不多做介绍了。我们在这里只要知道，require()用于加载模块就行了。
~~~

### 浏览器环境

~~~
由于一个重大的局限，使得CommonJS规范不适用于浏览器环境。还是上一节的代码，如果在浏览器中运行，会有一个很大的问题，你能看出来吗？
　　var math = require('math');
　　math.add(2, 3);
第二行math.add(2, 3)，在第一行require('math')之后运行，因此必须等math.js加载完成。也就是说，如果加载时间很长，整个应用就会停在那里等。
这对服务器端不是一个问题，因为所有的模块都存放在本地硬盘，可以同步加载完成，等待时间就是硬盘的读取时间。但是，对于浏览器，这却是一个大问题，因为模块都放在服务器端，等待时间取决于网速的快慢，可能要等很长时间，浏览器处于"假死"状态。
~~~

### AMD

~~~
AMD意思就是"异步模块定义"。它采用异步方式加载模块，模块的加载不影响它后面语句的运行。所有依赖这个模块的语句，都定义在一个回调函数中，等到加载完成之后，这个回调函数才会运行。
AMD也采用require()语句加载模块，但是不同于CommonJS，它要求两个参数：
　　require([module], callback);
第一个参数[module]，是一个数组，里面的成员就是要加载的模块；第二个参数callback，则是加载成功之后的回调函数。如果将前面的代码改写成AMD形式，就是下面这样：
　　require(['math'], function (math) {
　　　　math.add(2, 3);
　　});
math.add()与math模块加载不是同步的，浏览器不会发生假死。所以很显然，AMD比较适合浏览器环境。
目前，主要有两个Javascript库实现了AMD规范：require.js和curl.js。
~~~

### 为什么要用require.js？

~~~
最早的时候，所有Javascript代码都写在一个文件里面，只要加载这一个文件就够了。后来，代码越来越多，一个文件不够了，必须分成多个文件，依次加载。下面的网页代码，相信很多人都见过。
<script src="1.js"></script>
<script src="2.js"></script>
<script src="3.js"></script>
<script src="4.js"></script>
<script src="5.js"></script>
<script src="6.js"></script>
缺点：
1.浏览器会停止网页渲染，加载文件越多，网页失去响应的时间就会越长；
2.必须严格保证加载顺序（比如上例的1.js要在2.js的前面），依赖性最大的模块一定要放到最后加载，当依赖关系很复杂的时候，代码的编写和维护都会变得困难。
require.js的诞生，就是为了解决这两个问题：
1.实现js文件的异步加载，避免网页失去响应；
2.管理模块之间的依赖性，便于代码的编写和维护。
~~~

### require.js的加载

~~~
下载后，假定把它放在js子目录下面，就可以加载了。
<script src="js/require.js"></script>
有人可能会想到，加载这个文件，也可能造成网页失去响应。解决办法有两个，一个是把它放在网页底部加载，另一个是写成下面这样：
<script src="js/require.js" defer async="true" ></script>
async属性表明这个文件需要异步加载，避免网页失去响应。IE不支持这个属性，只支持defer，所以把defer也写上。
加载require.js以后，下一步就要加载我们自己的代码了。假定我们自己的代码文件是main.js，也放在js目录下面。那么，只需要写成下面这样就行了：
~~~

### 使用require.js

requireJs是使用head.appendChild()将每个依赖加载为一个script标签

- 模块的加载

~~~
require.config({
　　　　paths: {
　　　　　　"jquery": "jquery.min",
　　　　　　"bootstrap": "bootstrap.min",
　　　　　　"ztree": "ztree.min"
　　　　}
　　});
~~~

### 版本号

~~~
urlArgs: 'v=' + (new Date()).getTime()
~~~

1.如果某个模块在另一台主机上，也可以直接指定它的网址，比如：

~~~
require.config({
　　　　paths: {
　　　　　　"jquery": "https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min"
　　　　}
　　});

~~~

- 引用

~~~
假定主模块依赖jquery、bootstrap和ztree这三个模块，main.js就可以这样写：
　　require(['jquery', bootstrap, ztree], function ($, bootstrap, ztree){
　　　　// some code here
　　});
require.js会先加载jQuery、bootstrap和ztree，然后再运行回调函数。主模块的代码就写在回调函数中。
~~~

- baseUrl

~~~
html: html引入，baseUrl就是html本身

data-main: 使用data-main baseUrl就是data-main的文件路径

另一种则是直接改变基目录（baseUrl）。
　　require.config({
　　　　baseUrl: "js/lib",
　　　　paths: {
　　　　　　"jquery": "jquery.min",
　　　　　　"bootstrap": "bootstrap.min",
　　　　　　"ztree": "ztree.min"
　　　　}
　　});
~~~

- 加载非规范的模块

~~~
举例来说，bootstrap和ztree这两个库，都没有采用AMD规范编写。如果要加载它们的话，必须先定义它们的特征。
　　require.config({
　　　　shim: {
　　　　　　bootstrap:{
	            deps: ['jquery'],
　　　　　　　　exports: 'bs'
　　　　　　},
　　　　　　ztree: {
　　　　　　　　deps: ['jquery'],
　　　　　　　　exports: ztree
　　　　　　}
　　　　}
　　});
~~~

- 加载依赖的css

~~~
cnpm install require-css
引入css.min.js
require.config({
    baseUrl: 'js',
    paths: {
    	'css': 'component/require-css/css.min',
        'jquery': 'component/jquery/dist/jquery.min',
        'bootstrap': 'component/bootstrap/dist/js/bootstrap',
        'math':'common/math'
    },
    shim: {
　　　　　　bootstrap:{
　　　　　　　 exports: 'bootstrap',
	          deps: [
	          	'jquery',
	          	'css!../js/component/bootstrap/dist/css/bootstrap.min',
	          	]
　　　　　　},
　　　　},
    map: {
        '*' : {
            'css': 'component/require-css/css.min'
        }
    }
}
});
~~~

### 加载html

[https://github.com/requirejs/text](https://github.com/requirejs/text)



### 自定义模块

~~~
define(function (){
　　var add = function (x,y){
　　　　return x+y;
　　};
　　return {
　　　　add: add
　　};
});
~~~

打包

~~~
https://github.com/requirejs/r.js
~~~