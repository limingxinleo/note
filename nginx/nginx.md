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

### Nginx rewrite
~~~
location ~* ^/weixin/ {
    rewrite "^/weixin/(.*)$" http://weixin.phalcon.app/$1 last;
}
~~~

### Nginx 代理
> 当出现/phalcon/时进行代理

~~~
location /phalcon/ {
    proxy_pass http://phalcon.phalcon.app/;
}
~~~
> 所有的都代理

~~~
location / {
    proxy_pass  http://phalcon.app;
    proxy_set_header Host $host;
    proxy_set_header  X-Real-IP  $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
}
~~~

### Nginx 负载均衡
~~~
upstream phalcon.app {
    ip_hash;   #第一次配置负载用ip_hash来处理session，后期修改为session复制
    server  s1.phalcon.app;
    server  s2.phalcon.app;
}
~~~