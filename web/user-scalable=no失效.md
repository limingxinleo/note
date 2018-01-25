---
title: 移动端user-scalable=no失效
date: 2017-12-27 15:16:46
categories: "前端之巅"
tags: '前端'
---

## 移动端某些浏览器禁止双指缩放(user-scalable=no)失效的解决方案

### 做移动端开发，给页面头部添加了meta标签，并添加了user-scalable=no属性禁止双指或双击放大：

~~~
<meta name="viewport" content="initial-scale=1,maximum-scale=1, minimum-scale=1, user-scalable=no">
~~~

但有些移动端浏览器，比如IOS10以上的Safari，安卓系统下的UC浏览器、QQ浏览器等，为了更好的用户体验，并没有遵循开发者禁止缩放的指定，虽然meta标签按如上写法，但依然允许用户双指缩放和双击放大。

解决方法是再加一段js，通过 touchmove 事件判断多个手指（touches.length），并通过阻止事件冒泡 event.preventDefault() 来实现 。

写了个demo，大家可以参考，点这里可以在线预览:禁止移动端个别浏览器缩放

PS：实测UC浏览器在我们多次双指操作后，还是会突破我们的限制，实现系统级强制对页面按照用户的意愿双指缩放，淘宝、天猫等大厂的站也是一样，所以，通过web代码，完全实现禁止用户缩放，目前是无法实现的。心疼前端兄弟们一秒钟。。。


~~~
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<meta name="viewport" content="initial-scale=1,maximum-scale=1, minimum-scale=1, user-scalable=no">
<title>禁止移动端某些浏览器缩放</title>
</head>

<body>
<div>用两个手指试下，不能缩放哦!</div>
<style>
* {
padding: 0;
margin: 0;
}

html,
body {
width: 100%;
height: 100%;
}

div {
width: 70%;
height: 30%;
background: orange;
color: white;
text-align: center;
display: flex;
justify-content: center;
align-items: center;
font-size: 5vw;
position: absolute;
left: 50%;
top: 50%;
transform: translate(-50%, -50%);
}
</style>

<script type="text/javascript">
document.documentElement.addEventListener('touchmove', function(event) {
if (event.touches.length > 1) {
event.preventDefault();
}
}, false);
</script>

</body>

</html>
~~~