# Consul

## 安装

[官网安装](https://www.consul.io/downloads.html)

[Docker](https://hub.docker.com/r/library/consul/)

~~~bash
docker pull consul

docker run -d --name=dev-consul -e CONSUL_BIND_INTERFACE=eth0 -p 8300:8300 -p 8500:8500 consul
~~~

## 配置
~~~
{
    "data_dir": "/usr/local/consul/data",
    "client_addr": "0.0.0.0",
    "ports": {
        "dns": 53
    },
    "disable_update_check": true
}
~~~

## supervisor
~~~
[group:consul]
programs=consul_master

[program:consul_master]
command = consul agent -config-dir=/usr/local/consul/config -data-dir=/usr/local/consul/data -server -bootstrap-expect 3
autorestart = true
redirect_stderr = true
stdout_logfile = /usr/local/consul/logs/stdout.log
stdout_logfile_maxbytes = 500MB
stdout_logfile_backups = 5
stdout_capture_maxbytes = 1MB
stdout_events_enabled = false
loglevel = warn
~~~

## 11.11.111.111 为以上server的内网IP

~~~
[group:consul]
programs=consul_client

[program:consul_client]
command = consul agent -config-dir=/usr/local/consul/config -data-dir=/usr/local/consul/data -server -join 11.11.111.111
autorestart = true
redirect_stderr = true
stdout_logfile = /usr/local/consul/logs/stdout.log
stdout_logfile_maxbytes = 500MB
stdout_logfile_backups = 5
stdout_capture_maxbytes = 1MB
stdout_events_enabled = false
loglevel = warn
~~~

~~~
[group:consul]
programs=consul_observer

[program:consul_observer]
command = consul agent -config-dir=/usr/local/consul/config -data-dir=/usr/local/consul/data -join 11.11.111.111 -ui
autorestart = true
redirect_stderr = true
stdout_logfile = /usr/local/consul/logs/stdout.log
stdout_logfile_maxbytes = 500MB
stdout_logfile_backups = 5
stdout_capture_maxbytes = 1MB
stdout_events_enabled = false
loglevel = warn
~~~