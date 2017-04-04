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