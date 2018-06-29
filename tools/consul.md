## Consul

### 安装

[官网安装](https://www.consul.io/downloads.html)

[Docker](https://hub.docker.com/r/library/consul/)

~~~bash
docker pull consul

docker run -d --name=dev-consul -e CONSUL_BIND_INTERFACE=eth0 -p 8300:8300 -p 8500:8500 consul
~~~