## Nginx
### 安装
MAC
~~~
brew install nginx-full --with-status --with-lua-module --with-redis2-module --with-redis2-module
brew install openresty
~~~
Linux 【增加lua扩展】
(https://github.com/openresty/lua-nginx-module#installation)[https://github.com/openresty/lua-nginx-module#installation]
~~~
yum install nginx
下载 ngx_devel_kit ngx_lua 源码
记录 nginx -V 的配置
--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie' \
--add-module=/_html/tools/nginx/ngx_devel_kit-0.3.0 \
--add-module=/_html/tools/nginx/lua-nginx-module-0.10.9rc7
make 
mv /usr/sbin/nginx /usr/sbin/nginx.bak
ln -s /_html/tools/nginx/objs/nginx /usr/sbin/nginx
nginx -s stop
nginx
~~~

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
server {
    listen       80;
    server_name  phalcon.app;
    location / { 
        proxy_pass          http://s.phalcon.app;
        proxy_set_header    Host                $host:$server_port;
        proxy_set_header    X-Real-IP           $remote_addr;
        proxy_set_header    X-Real-PORT         $remote_port;
        proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
    }
}
~~~

### Nginx 负载均衡
~~~
upstream upstream_nginx {
    #ip_hash;   #ip_hash来处理session
    server  127.0.0.1:8080 weight=10;
    server  127.0.0.1:8081 weight=10;
}

server {
    listen       80;
    server_name  s.nginx.app;
    location / { 
        proxy_pass          http://upstream_nginx;
        proxy_set_header    Host                $host:$server_port;
        proxy_set_header    X-Real-IP           $remote_addr;
        proxy_set_header    X-Real-PORT         $remote_port;
        proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
    }
}

server {
     listen       8080;
     server_name  s.nginx.app;
     ...
}
 
server {
    listen       8081;
    server_name  s.nginx.app;
    ...
}
~~~

### Nginx Lua 执行顺序
~~~
init_by_lua            http
set_by_lua             server, server if, location, location if
rewrite_by_lua         http, server, location, location if
access_by_lua          http, server, location, location if
content_by_lua         location, location if
header_filter_by_lua   http, server, location, location if
body_filter_by_lua     http, server, location, location if
log_by_lua             http, server, location, location if
timer
~~~

### Nginx Lua 注释
~~~
init_by_lua:
在nginx重新加载配置文件时，运行里面lua脚本，常用于全局变量的申请。
例如lua_shared_dict共享内存的申请，只有当nginx重起后，共享内存数据才清空，这常用于统计。

set_by_lua:
设置一个变量，常用与计算一个逻辑，然后返回结果
该阶段不能运行Output API、Control API、Subrequest API、Cosocket API

rewrite_by_lua:
在access阶段前运行，主要用于rewrite

access_by_lua:
主要用于访问控制，能收集到大部分变量，类似status需要在log阶段才有。
这条指令运行于nginx access阶段的末尾，因此总是在 allow 和 deny 这样的指令之后运行，虽然它们同属 access 阶段。

content_by_lua:
阶段是所有请求处理阶段中最为重要的一个，运行在这个阶段的配置指令一般都肩负着生成内容（content）并输出HTTP响应。

header_filter_by_lua:
一般只用于设置Cookie和Headers等
该阶段不能运行Output API、Control API、Subrequest API、Cosocket API

body_filter_by_lua:
一般会在一次请求中被调用多次, 因为这是实现基于 HTTP 1.1 chunked 编码的所谓“流式输出”的。
该阶段不能运行Output API、Control API、Subrequest API、Cosocket API

log_by_lua:
该阶段总是运行在请求结束的时候，用于请求的后续操作，如在共享内存中进行统计数据,如果要高精确的数据统计，应该使用body_filter_by_lua。
该阶段不能运行Output API、Control API、Subrequest API、Cosocket API

timer:
~~~

### Location
* 匹配规则
1. 普通、正则先　普通location 再匹配正则location。如果正则location存在则命中正则location，否则命中普通location。
2. 普通location 命中长度长的location。

* 匹配前缀
~~~
~ 大小写敏感　正则匹配 
~* 大小写不敏感　正则匹配 
!~ 大小写敏感　正则不匹配 
!~* 大小写不敏感　正则不匹配

＝ 前缀与uri完全相同　普通匹配
^~ 不进行正则匹配　普通匹配
不填 前缀匹配　普通匹配
~~~

### PATH_INFO
(http://www.nginx.cn/426.html)[http://www.nginx.cn/426.html]

### TCP负载均衡
1. 首先编译Nginx stream模块
~~~
MAC:
brew reinstall nginx-full --with-stream

Linux:
# yum源默认自带
yum install nginx 
~~~

2. 修改nginx.conf
> 低版本Nginx可能不支持stream下log_format

~~~
# 增加以下 具体配置放到同级streams下
error_log  /Users/limx/Applications/runtime/nginx/error.log;

stream {
    log_format log_format_stream '$remote_addr [$time_local] '
                 '$protocol $status $bytes_sent $bytes_received '
                 '$session_time "$upstream_addr" '
                 '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

    access_log /Users/limx/Applications/runtime/nginx/tcp-access.log log_format_stream;
    include streams/*.conf;
}
~~~

3. 编写配置 streams/demo.conf
- max_conns=5 最大连接数
- fail_timeout=30 在这个时间段中进行了多少次连接的尝试失败了，那么就认为是不可达了并标记不可达
- max_fails=5 和上面是对应上的尝试失败次数。
- backup 标记server为备用server
- done 标记server不可用
- slow_start=30 当server从不健康变成健康服务时，权重由0变为标准值的时间
- zone [name] [size] 定义共享内存区域的名称和大小，该组存储组的配置和运行时状态是在进程之间共享的。

~~~
upstream tcp_upstream_default {
    zone upstream_dynamic 64k;
    server  127.0.0.1:12001 weight=10;
    server  127.0.0.1:12002 weight=5 fail_timeout=30 max_fails=5;
}

server {
    listen                      12000;
    proxy_connect_timeout       5s;
    proxy_timeout               30s;
    proxy_pass                  tcp_upstream_default;
}
~~~

### 编译Rtmp扩展
MAC
~~~
brew install nginx-full --with-status --with-stream --with-rtmp-module
~~~

Linux
* 确定Nginx版本 我这里是v1.12.2 
~~~
$ nginx -v 
~~~

* 确定已编译的扩展
~~~
$ nginx -V 
结果如下：
--prefix=/etc/nginx --sbin-path=/usr/local/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie'
~~~

* 下载最新扩展 和 Nginx
~~~
$ wget https://github.com/arut/nginx-rtmp-module/archive/v1.2.0.zip
$ wget http://nginx.org/download/nginx-1.12.2.tar.gz
~~~

* 编译
> 进入nginx-1.12.2目录编译Nginx 参数为之前nginx -V 显示的参数 在最后增加 --add-module=/_html/tools/nginx/nginx-rtmp-module-1.2.0

~~~
$ ./configure --prefix=/etc/nginx --sbin-path=/usr/local/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie' --add-module=/_html/tools/nginx/nginx-rtmp-module-1.2.0
$ make
~~~

* 建立软连接 /_html/tools/nginx/nginx-1.12.2/objs/nginx 为编译好的脚本
~~~
$ cd /usr/local/sbin
$ ln -s /_html/tools/nginx/nginx-1.12.2/objs/nginx nginx
~~~

* 重启终端测试
~~~
$ nginx -V
$ nginx -t
~~~

* 配置 nginx.conf
~~~
rtmp {
    include rtmp/*.conf;
}
~~~

* 配置demo.conf
vim rtmp/demo.conf
~~~smartyconfig
server {
    listen 13001;
    chunk_size 4096;
    
    application rtmp {
        live on;
        # record keyframes;
        # record_path /tmp;
        # record_max_size 128k;
        # record_interval 30s;
        # record_suffix .this.is.flv;
        
        # on_publish http://localhost:8080/publish;
        # on_play http://localhost:8080/play;
        # on_record_done http://localhost:8080/record_donw;
    }
    
    application hls {
        live on;
        hls on;
        hls_path /Users/limx/Applications/runtime/rtmp/hls;
        hls_fragment 10s;     #每个视频切片的时长。
        hls_playlist_length 60s;  #总共可以回看的事件，这里设置的是1分钟。
        #hls_continuous on; #连续模式。
        #hls_cleanup on;    #对多余的切片进行删除。
        #hls_nested on;     #嵌套模式。
    }
}
~~~

* 配置http下rtmp_demo.conf
~~~smartyconfig
server {
    listen 80;
    server_name rtmp.demo.app;
    
    location /stat {
        rtmp_stat all;
        rtmp_stat_stylesheet stat.xsl;
    }
    
    location /stat.xsl {
        root /usr/local/share/rtmp-nginx-module;
    }
    
    location /hls {
        types{
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
        #alias /tmp/app;
        root /Users/limx/Applications/runtime/rtmp;
        expires -1;
    }
    
    location / {
        root /usr/local/share/rtmp-nginx-module/test/rtmp-publisher;
    }
}
~~~

* 直播测试 rtmp
~~~
ffmpeg 模拟推流
$ ffmpeg -re -i test.mp4 -f flv rtmp:127.0.0.1:13001/rtmp/test1
mpv 模拟观看
$ mpv rtmp://127.0.0.1:13001/rtmp/test1
~~~

* 直播测试 hls
~~~
ffmpeg 模拟推流
$ ffmpeg -re -i test.mp4 -f flv rtmp:127.0.0.1:13001/hls/test1

H5
<video autoplay webkit-playsinline>      
    <source src="http://rtmp.demo.app/hls/test1.m3u8" type="application/vnd.apple.mpegurl" />      
    <p class="warning">Your browser does not support HTML5 video.</p>   
</video>
~~~

### 静态资源配置
~~~
location ~ \.(gif|jpg|png|htm|html|css|js|flv|ico|swf)$ {
    # proxy_pass http://appserver;
    # proxy_redirect off;
    # proxy_set_header Host $host;
    # proxy_cache cache_one;
    # proxy_cache_valid 200 302 1h;
    # proxy_cache_valid 301 1d;
    # proxy_cache_valid any 1m;
    expires 30d;
}
~~~

### 错误页面
~~~smartyconfig
server {
    error_page 413 = @d413;
    location @d413 {
        default_type application/json;
        return 200 '{"status":"error","result":{"error_msg":"内容太长了","error_code":""}}';
    }
}
~~~

### access日志常用格式
~~~
log_format  main  '$remote_addr - $remote_user [$time_local] '
      'fwf[$http_x_forwarded_for] tip[$http_true_client_ip] '
      '[$upstream_addr] [$upstream_response_time] [$request_time] '
      '$http_host "$request" '
      '"$status" $body_bytes_sent "$http_referer" '
      '"$http_accept_language" "$http_user_agent" ';
~~~

### error日志格式
~~~
YYYY/MM/DD HH:MM:SS [LEVEL] PID#TID: *CID MESSAGE
# 对应正则
(\d+\/\d+\/\d+\s\S+)\s\[(\w+)\]\s(\d+)#(\d+):\s\*(\d+)\s(.*)
~~~

