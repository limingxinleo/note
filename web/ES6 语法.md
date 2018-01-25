---
title: ES6语法
date: 2017-04-14 15:16:46
categories: "前端之巅"
tags: '前端'
---

这两周接触了小程序感觉把大部分的坑都踩了下
看到小程序能写es6语法
es6语法有什么好处呢！就去看了看下面我来说说我学到的

### Class
ES6中添加了对类的支持，引入了class关键字，想了解ES5对象语法的可以敲javascript中的面向对象

~~~
//定义类
 class Cons{
  constructor(name,age){
  
    this.name = name;    
    this.age = age;

  }

  getMes(){
    
    console.log(`hello ${this.name} !`);

  }

}
let mesge = new Cons('啦啦啦~',21);
mesge.getMes();

//继承

class Ctrn extends Cons{
  constructor(name,anu){
  
    super(name);  //等同于super.constructor(x)
    this.anu = anu;

  }

  ingo(){
     console.log(`my name is ${this.name},this year ${this.anu}`);
  }

}
let ster = new Ctrn('will',21);
ster.ingo();
ster.getMes();
~~~

### 箭头操作符
新增的箭头操作符=>便有异曲同工之妙。它简化了函数的书写
~~~
var arr = [1, 2, 3];

//ES5

arr.forEach(function(x) {

    console.log(x);
    
});
    
//ES6

arr.forEach(x = > console.log(x));
~~~

### 解构赋值
数组中的值会自动被解析到对应接收该值的变量中

~~~
var [name,,age] = ['will','lala','21'];

console.log('name:'+name+', age:'+age);//输出：name:will, age:21
~~~

### 默认参数

~~~
//ES5

function fn(name){	
	var name=name||'will';
	console.log('my name is '+name);
}

//ES6

function fn(name='will'){

	console.log(`my name is ${name}`);
	
}
~~~

### 多行字符串
使用反引号`来创建字符串
~~~
var str = 'The 3.1 work extends XPath and'
  +'XQuery with map and array data structures'
  +'along with additional functions and operators'
  +'for manipulating them; a primary motivation'
  +'was to enhance JSON support.';

//ES6

var roadPoem = `The 3.1 work extends XPath and
  XQuery with map and array data structures
  along with additional functions and operators
  for manipulating them; a primary motivation
  was to enhance JSON support.`;
~~~

### 字符串模板
由美元符号加花括号包裹的变量${name}
~~~
var name = 'will';

console.log(`my name is ${name}`);
~~~

### 扩展运算符
在函数中使用命名参数同时接收不定数量的未命名参数，在以前的JavaScript代码中我们可以通过arguments变量来达到这一目的。而ES6中是如下实现的
~~~
function add(...x){

	return x.reduce((m,n)=>m+n);
	
}

console.log(add(1,2,3));//输出：6

console.log(add(1,2,3,4,5));//输出：15
~~~

### 块级作用域
let与const 关键字！可以把let看成var，它定义的变量被限定在了特定范围内。const则用来定义常量，即无法被更改值的变量。共同点都是块级作用域。
~~~
//let

for (let i=0;i<2;i++){

  console.log(i);//输出: 0,1

  }
console.log(i);//输出：undefined

//const

const name='a';
name='b';   //报错
~~~

### 模块
在ES6标准中支持module了,将不同功能的代码分别写在不同文件中，各模块只需使用export导出公共接口部分，然后通过使用module模块的导入的方式可以在其他地方使用
~~~
// b.js

function fn(){

    console.log('hello world');
    
}
 
export fn;  // a.js

module { fn } from "./b";
 
fn();

//然后在HTML引入a文件运行浏览器
~~~

### for or
我们都知道for in循环用于遍历数组，类数组或对象，ES6中新引入的for of循环功能相似，不同的是每次循环它提供的不是序号而是值。
~~~
var arr = [ "a", "b", "c" ]; 
for (v of arr) {

    console.log(v);//输出 a,b,c

}
~~~

了解更多 可以查看阮一峰的[ECMAScript](http://es6.ruanyifeng.com/#docs/promise)
