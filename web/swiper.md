---
title: Swiper
date: 2017-03-11 15:16:46
categories: "前端之巅"
tags: '前端'
---

### Swiper框架[可达到效果](http://www.weikecj.cn/template.jsp)

- Swiper是纯javascript打造的滑动特效插件，面向手机、 平板电脑等移动终端。
- Swiper能实现触屏焦点图、触屏Tab切换、触屏多图切换 等常用效果。
- Swiper开源、免费、稳定、使用简单、功能强大，是架 构移动终端网站的重要选择。

### 参考网站

1.[Swiper官网](swiper.com.cn):swiper.com.cn

2.[Swiper Animate使用方法](swiper.com.cn/usage/animate):swiper.com.cn/usage/animate

3.[官方效果演示](swiper.com.cn/demo):swiper.com.cn/demo

4.[参考效果](eqxiu.com/s/D797iu2w):eqxiu.com/s/D797iu2w

### Swiper基础文件

1.swiper库核心js文件:swiper-3.2.7.min.js

2.swiper库核心css文件:swiper-3.2.7.min.css

### Swiper Animate

1.Swiper Animate是用于在Swiper内快速制作CSS3动画 效果的小插件，写法简单，功能强大 。

2.swiper animate库核心js文件:swiper.animate.min.js

3.swiper animate库核心css文件:animate.min.css

### rem和vw区别
-

### rem

[rem](https://isux.tencent.com/web-app-rem.html)


1.rem 在页面当中在body设置一个基准值 在body设置font-size：10px 其他地方设置大小相对于body设置 例如设置p标签2rem 那么他最终实际大小就是20

2.rem 最早用于@media做不同的css响应的时候用的是rem

### vw

1.vw 他指的是屏幕的百分比  例如：指定文字大小font-size:10vw,他的大小就是屏幕的宽度*10%

2.vw可以轻松搞定弹性布局（CSS3引入了一种新的布局模式——Flexbox布局，即伸缩布局盒模型（Flexible Box），用来提供一个更加有效的方式制定、调整和分布一个容器里项目布局，即使它们的大小是未知或者动态的，这里简称为Flex。），流体布局（简单的来说，就是网页缩小和放大时网页布局会随着浏览器的大小而改变！）。

### [弹性布局优势](http://blog.csdn.net/practicer2015/article/details/46454821)

1.屏幕和浏览器窗口大小发生改变也可以灵活调整布局；

2.可以控制元素在页面上的布局方向；

3.可以按照不同于文档对象模型（DOM）所指定排序方式对屏幕上的元素重新排序。也就是说可以在浏览器渲染中不按照文档流先后顺序重排伸缩项目顺序。

### click事件[tap](http://www.runoob.com/jquerymobile/jquerymobile-panels.html)事件区别

1.两者都会在点击时触发，但是在手机WEB端，click会有 200~300 ms，所以请用tap代替click作为点击事件。

singleTap和doubleTap 分别代表单次点击和双次点击。

2.处理方式：github上有一个叫做fastclick的库，它也能规避移动设备上click事件的延迟响应[地址](https://github.com/ftlabs/fastclick) 实际开发中当元素绑定fastclick后，click响应速度比tap还要快一点点。

### H5触摸事件

现今大多数触屏手机webkit内核提供了touch事件的监听：touchstart,touchmove,touchend,touchcancel

1.touchstart ： 当手指触摸到屏幕会触发；

2.touchmove : 当手指在屏幕上移动时，会触发；

3.touchend : 当手指离开屏幕时，会触发；

4.touchcancel : 当你的手指还没有离开屏幕时，有系统级的操作发生时就会触发
