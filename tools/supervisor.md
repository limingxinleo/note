## Supervisor
进程管理器

### 安装
~~~
yum install supervisor
~~~

### 启动
~~~
supervisord -c /etc/supervisord.conf
~~~

### Laravel 消息队列 使用
~~~
[program:laravelQueue]
command                 = php artisan queue:work
directory               = /path/to/app
process_name            = %(program_name)s_%(process_num)s
numprocs                = 6
autostart               = true
autorestart             = true
stdout_logfile          = /path/to/app/storage/logs/supervisor_waaQueue.log
stdout_logfile_maxbytes = 10MB
stderr_logfile          = /path/to/app/storage/logs/supervisor_wqqQueue.log
stderr_logfile_maxbytes = 10MB
~~~

### 使用
编辑/etc/supervisord.d/demo.ini
~~~
[program:queue-demo]
command                 = ./server
directory               = /_html/html/phalcon/thrift-go-phalcon-project
process_name            = %(program_name)s_%(process_num)s
~~~

### simple-subcontroller.phalcon 消息队列使用
编辑/etc/supervisord.d/queue-phalcon-demo.ini
~~~
[program:queue-phalcon-demo]
command                 = php run Test\\Queue
directory               = /_html/html/phalcon/demo
process_name            = %(program_name)s
user                    = nginx
~~~