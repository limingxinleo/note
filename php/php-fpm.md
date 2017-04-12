## FastCGI Process Manage

### sock通信
创建Socket文件
~~~
cd /dev/shm
touch PHP-fcgi.sock
chown nginx.nginx php-fcgi.sock
chmod 777 php-fcgi.sock
~~~

修改配置
~~~
fastcgi_pass            unix:/dev/shm/php-fcgi.sock;
~~~

重启
~~~
nginx -s reload
php-fpm                 【需要完全重启】
~~~

### php-fpm调优
> php-fpm进程池开启进程有两种方式，一种是static，直接开启指定数量的php-fpm进程，不再增加或者减少。
> 另一种则是dynamic，开始时开启一定数量的php-fpm进程，当请求量变大时，动态的增加php-fpm进程数到上限，当空闲时自动释放空闲的进程数到一个下限。

* pm.max_children
静态方式下开启的php-fpm进程数量，在动态方式下他限定php-fpm的最大进程数（这里要注意pm.max_spare_servers的值只能小于等于pm.max_children）
> 估算pm.max_children = (MAX_MEMORY - 500MB) / 25MB

* pm.start_servers
动态方式下的起始php-fpm进程数量。
> max_children的十分之一

* pm.min_spare_servers
动态方式空闲状态下的最小php-fpm进程数量。

* pm.max_spare_servers
动态方式空闲状态下的最大php-fpm进程数量。

> 如果dm设置为static，那么其实只有pm.max_children这个参数生效。系统会开启参数设置数量的php-fpm进程。
> 如果dm设置为dynamic，4个参数都生效。系统会在php-fpm运行开始时启动pm.start_servers个php-fpm进程，然后根据系统的需求动态在pm.min_spare_servers和pm.max_spare_servers之间调整php-fpm进程数。

