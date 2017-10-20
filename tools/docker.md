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

# 安装
docker pull mysql
# Run
docker run --name mysql --restart unless-stopped -p 3306:3306 -e MYSQL_ROOT_PASSWORD=910123 -d -v /mnt/mysql:/var/lib/mysql mysql
# Stop
docker stop mysql
# Start
docker start mysql

docker run --name elasticsearch --restart unless-stopped -p 9200:9200 -p 9300:9300 \
-v /mnt/elasticsearch/data:/usr/share/elasticsearch/data -e ES_JAVA_OPTS="-Xms128m -Xmx128m" \
-e "discovery.type=single-node" -d elasticsearch
~~~