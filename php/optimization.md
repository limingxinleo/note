## php优化办法

### Zend OPcache
使用webbench测试网站框架压力
webbench -c 400 -t 10 url
~~~
PHP 7.0.18 (cli) (built: Apr 11 2017 13:29:03) ( NTS )
Copyright (c) 1997-2017 The PHP Group
Zend Engine v3.0.0, Copyright (c) 1998-2017 Zend Technologies
    with Zend OPcache v7.0.18, Copyright (c) 1999-2017, by Zend Technologies
~~~
以下测试都是在控制器中输出HELLO WORLD

1.没有使用Zend OPcache时
~~~
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.

Request:
GET /index/hello HTTP/1.0
User-Agent: WebBench 1.5
Host: 54.laravel.demo.lmx0536.cn


Runing info: 400 clients, running 10 sec.

Speed=1110 pages/min, 13987 bytes/sec.
Requests: 141 susceed, 44 failed.
~~~

~~~
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.

Request:
GET /index/hello HTTP/1.0
User-Agent: WebBench 1.5
Host: 54.lumen.demo.lmx0536.cn


Runing info: 400 clients, running 10 sec.

Speed=3552 pages/min, 11892 bytes/sec.
Requests: 569 susceed, 23 failed.
~~~

~~~
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.

Request:
GET /test/index/hello HTTP/1.0
User-Agent: WebBench 1.5
Host: phalcon.demo.lmx0536.cn


Runing info: 400 clients, running 10 sec.

Speed=10452 pages/min, 57006 bytes/sec.
Requests: 1663 susceed, 79 failed.
~~~

2.使用Zend OPcache时
~~~
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.

Request:
GET /index/hello HTTP/1.0
User-Agent: WebBench 1.5
Host: 54.laravel.demo.lmx0536.cn


Runing info: 400 clients, running 10 sec.

Speed=6348 pages/min, 105046 bytes/sec.
Requests: 1058 susceed, 0 failed.
~~~

~~~
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.

Request:
GET /index/hello HTTP/1.0
User-Agent: WebBench 1.5
Host: 54.lumen.demo.lmx0536.cn


Runing info: 400 clients, running 10 sec.

Speed=15972 pages/min, 55698 bytes/sec.
Requests: 2662 susceed, 0 failed.
~~~

~~~
Webbench - Simple Web Benchmark 1.5
Copyright (c) Radim Kolar 1997-2004, GPL Open Source Software.

Request:
GET /test/index/hello HTTP/1.0
User-Agent: WebBench 1.5
Host: phalcon.demo.lmx0536.cn


Runing info: 400 clients, running 10 sec.

Speed=12384 pages/min, 70966 bytes/sec.
Requests: 2064 susceed, 0 failed.
~~~

结论：
从测试中可以看得出OPcache对性能的提升是显著的。
> PS:laravel和lumen为空框架。phalcon里加载了部分服务。

