# 如何单机部署 Hyperf 项目

公司一直使用 `Swarm` 集群，所以从来没有考虑过这个问题，但群里的小伙伴多次问到 `上线部署` 的问题，这里就详细提供一种方式。

再继续往下看前，请小伙伴大体了解一下 `Nginx` 的 `Upstream` 配置和 `Docker` 的基本使用方法。

> 以下 legal_api 为项目名
> 
## 配置 Nginx

```
upstream legal_api {
    server 127.0.0.1:10090;
    server 127.0.0.1:10091;
}
server {
    listen       80;
    server_name  legal-api.xxx.cn;
    location / {
        proxy_pass          http://legal_api;
        proxy_set_header    Host                $host:$server_port;
        proxy_set_header    X-Real-IP           $remote_addr;
        proxy_set_header    X-Real-PORT         $remote_port;
        proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
    }
}
```

## 编写重启脚本

```sh
# 拉取最新的镜像
docker pull registry.cn-shanghai.aliyuncs.com/xxx/legal_api:latest
sleep 1

# 关闭正在运行的 legal_api 容器
docker stop legal_api && docker rm legal_api
sleep 1

# 启动新的容器
docker run -d --restart always -p 10090:9501 -v /www/limx/legal_api.env:/opt/www/.env --name legal_api registry.cn-shanghai.aliyuncs.com/xxx/legal_api:latest
sleep 1

# 关闭正在运行的 legal_api2 容器
docker stop legal_api2 && docker rm legal_api2
sleep 1

# 启动新的容器
docker run -d --restart always -p 10091:9501 -v /www/limx/legal_api.env:/opt/www/.env --name legal_api2 registry.cn-shanghai.aliyuncs.com/xxx/legal_api:latest

```

## 更新项目

本地打包并上传，然后到服务器上执行脚本

```
$ ./refresh_legal_api.sh
latest: Pulling from xxx/legal_api
Digest: sha256:37304ae814c89f2da8b7f4f1a6301d8d14150fe3d319e3a60126a6fcb37a0d7f
Status: Image is up to date for registry.cn-shanghai.aliyuncs.com/xxx/legal_api:latest
legal_api
legal_api
9105f2a081462bb74498a4f18d770680469f1a7de2854d8a7c51e1e532b2d43b
legal_api2
legal_api2
be7a388d9dd51de7c24a8a4a6468ac31b07cb0ca83e55a421cd6637ef9fbf64c
```