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

### 命令
~~~
supervisord -c /etc/supervisord.conf，初始启动Supervisord，启动、管理配置中设置的进程。
supervisorctl stop programxxx，停止某一个进程(programxxx)，programxxx为[program:blogdemon]里配置的值，这个示例就是blogdemon。
supervisorctl start programxxx，启动某个进程
supervisorctl restart programxxx，重启某个进程
supervisorctl stop all，停止全部进程，注：start、restart、stop都不会载入最新的配置文件。
supervisorctl reload，载入最新的配置文件，并按新的配置启动、管理所有进程。
~~~

### Laravel 消息队列 使用
~~~
[program:laravelQueue]
command                 = php artisan queue:work
directory               = /path/to/app
process_name            = %(process_num)s
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

### swoft使用示例
~~~
[group:swoft]
programs=swoft_queue

;通用消息队列脚本
[program:swoft_queue]
command = bin/swoft queue:handle
autorestart = true
redirect_stderr = true
stopsignal = QUIT
stdout_logfile = /data/logs/supervisor-swoft-queue.log
stdout_logfile_maxbytes = 500MB
stdout_logfile_backups = 5
stdout_capture_maxbytes = 1MB
stdout_events_enabled = false
loglevel = warn
user = www
~~~