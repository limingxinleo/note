## Docker

### 查看内网地址
~~~
docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONTAINER_ID
~~~

### Linux 安装
Centos
~~~
yum install docker
service docker start

# 修改为国内镜像
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://xxxx.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
~~~