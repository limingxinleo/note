---
title: ES6语法 Promise 对象
date: 2017-04-15 15:16:46
categories: "前端之巅"
tags: '前端'
---


前后端分离项目进公司终于实践到了，但是同时发送3次ajax加载数据就会有先后的问题

解决方法：
1.后端就把前端要的数据接口给整合好返回，这样只用请求一次就可以了

2.回调套回调 在发送第一个ajax请求成功后再发送第二个请求（这样就会有处在性能上的问题，而且会导致代码不够直观，就是常说的 Callback Hell）

3.第三个就是我现在学习了es6学到的一个方法：（ES6 的 Promise 对象）

### 什么是 Promise
一个 Promise 对象可以理解为一次将要执行的操作（常常被用于异步操作），使用了 Promise 对象之后可以用一种链式调用的方式来组织代码，让代码更加直观。而且由于 Promise.all 这样的方法存在，可以让同时执行多个操作变得简单。接下来就来简单介绍 Promise 对象。

### resolve 和 reject
下面的代码实现的功能非常简单，helloWord 函数接受一个参数，如果为 true 就打印 "Hello World!"，如果为 false 就打印错误的信息。helloWord 函数返回的是一个 Promise 对象。
在 Promise 对象当中有两个重要方法————resolve 和 reject。
resolve 方法可以使 Promise 对象的状态改变成成功，同时传递一个参数用于后续成功后的操作，在这个例子当中就是 Hello World! 字符串。
reject 方法则是将 Promise 对象的状态改变为失败，同时将错误的信息传递到后续错误处理的操作。
~~~
function helloWorld (ready) {
    return new Promise(function (resolve, reject) {
        if (ready) {
            resolve("Hello World!");
        } else {
            reject("Good bye!");
        }
    });
}

helloWorld(true).then(function (message) {
    alert(message);
}, function (error) {
    alert(error);
});
~~~

### Promise 的三种状态

- Fulfilled 可以理解为成功的状态
- Rejected 可以理解为失败的状态
- Pending 既不是 Fulfilld 也不是 Rejected 的状态，可以理解为 Promise 对象实例创建时候的初始状态

helloWorld 的例子中的 then 方法就是根据 Promise 对象的状态来确定执行的操作，resolve 时执行第一个函数（onFulfilled），reject 时执行第二个函数（onRejected）。

### then

helloWorld 的例子当中利用了 then(onFulfilld, onRejected) 方法来执行一个任务打印 "Hello World!"，在多个任务的情况下 then 方法同样可以用一个清晰的方式完成。

~~~
function printHello (ready) {
    return new Promise(function (resolve, reject) {
        if (ready) {
            resolve("Hello");
        } else {
            reject("Good bye!");
        }
    });
}

function printWorld () {
    alert("World");
}

function printExclamation () {
    alert("!");
}

printHello(true)
    .then(function(message){
        alert(message);
    })
    .then(printWorld)
    .then(printExclamation);
~~~
上述例子通过链式调用的方式，按顺序打印出了相应的内容。then 可以使用链式调用的写法原因在于，每一次执行该方法时总是会返回一个 Promise 对象。另外，在 then onFulfilled 的函数当中的返回值，可以作为后续操作的参数，因此上面的例子也可以写成：
~~~
printHello(true).then(function (message) {
    return message;
}).then(function (message) {
    return message  + ' World';
}).then(function (message) {
    return message + '!';
}).then(function (message) {
    alert(message);
});
~~~
同样可以打印出正确的内容。

### Promise.all 和 Promise.race
Promise.all 可以接收一个元素为 Promise 对象的数组作为参数，当这个数组里面所有的 Promise 对象都变为 resolve 时，该方法才会返回。
~~~
var step1 = new Promise(function(resolve,reject){
	$.ajax({
		.....
		success:function(data){
			resolve(data);
		}
	})
})

var step2 = new Promise(function(resolve,reject){
	$.ajax({
		.....
		success:function(data){
			resolve(data);
		}
	})
})

var step3 = new Promise(function(resolve,reject){
	$.ajax({
		.....
		success:function(data){
			resolve(data);
		}
	})
})
//等所有步骤都完毕之后,会执行all的then方法
Promise.all([step1,step2,step3]).then(function(re){
	//这里re[0]表示step1里resolve(data);中的data
	//这里re[1]表示step2里resolve(data);中的data
	//这里re[2]表示step3里resolve(data);中的data
})
~~~
上面的例子模拟了传输两个数据需要不同的时长，虽然 step3 的速度比 step1，step2 要快，但是 Promise.all 方法会按照数组里面的顺序将结果返回。
日常开发中经常会遇到这样的需求，在不同的接口请求数据然后拼合成自己所需的数据，通常这些接口之间没有关联（例如不需要前一个接口的数据作为后一个接口的参数），这个时候 Promise.all 方法就可以派上用场了。
还有一个和 Promise.all 相类似的方法 Promise.race，它同样接收一个数组，不同的是只要该数组中的 Promise 对象的状态发生变化（无论是 resolve 还是 reject）该方法都会返回。







