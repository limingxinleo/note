## Nginx

### Nginx 调优
先查看一下机器的cpu合数 
~~~
cat /proc/cpuinfo | grep processor
~~~

* worker_processes
设置为cpu核数

* events
~~~
events {
     # 语法  use [ kqueue | rtsig | epoll | /dev/poll | select | poll ];
     use epoll;                         # 使用epoll（linux2.6的高性能方式）
     worker_connections 51200;          #每个进程最大连接数（最大连接=连接数×进程数）

     # 并发总数是 worker_processes 和 worker_connections 的乘积
     # 即 max_clients = worker_processes * worker_connections
     # 在设置了反向代理的情况下，max_clients = worker_processes * worker_connections / 4
     # 并发受IO约束，max_clients的值须小于系统可以打开的最大文件数
     # 查看系统可以打开的最大文件数
     # cat /proc/sys/fs/file-max
}
~~~