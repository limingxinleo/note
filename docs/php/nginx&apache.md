# Apache与Nginx的优缺点比较 

## nginx相对于apache的优点
* 轻量级，同样起web 服务，比apache 占用更少的内存及资源 
* 抗并发，nginx 处理请求是异步非阻塞的，而apache 则是阻塞型的，在高并发下nginx 能保持低资源低消耗高性能
* 高度模块化的设计，编写模块相对简单
* 社区活跃，各种高性能模块出品迅速啊 

## apache 相对于nginx 的优点
* rewrite ，比nginx 的rewrite 强大 
* 模块超多，基本想到的都可以找到
* 少bug ，nginx 的bug 相对较多
* 超稳定 

## 最核心的区别
* apache是同步多进程模型，一个连接对应一个进程
* nginx是异步的，多个连接（万级别）可以对应一个进程