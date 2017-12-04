## Docker

### 查看内网地址
~~~
docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONTAINER_ID
~~~


### Linux 安装
[阿里云国内镜像](https://cr.console.aliyun.com/?spm=5176.2020520152.210.d103.5dbcab35Pfdw0h#/accelerator)

Centos
~~~
yum install docker
yum install docker-compose
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

docker run --name redis --restart unless-stopped -p 6379:6379 -v /mnt/redis/data:/data  -d redis redis-server --appendonly yes
~~~


### docker-compose

#### 报错解决
1. Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?
~~~
$ sudo docker-compose up -d

ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?

If it's at a non-standard location, specify the URL with the DOCKER_HOST environment variable.

# 解决：设置DOCKER_HOST，我的docker跑在sock上，所以按照如下设置
export DOCKER_HOST=/var/run/docker.sock
~~~

#### 配置docker-compose.yml
1. Mysql
~~~yaml
mysql:
    image: mysql
    environment:
        MYSQL_ROOT_PASSWORD: 910123
    ports:
        - "3306:3306"
    volumes:
        - "/mnt/mysql:/var/lib/mysql"

~~~

2. Redis
~~~yaml
redis:
    image: redis
    ports:
        - "6379:6379"
    volumes:
        - "/mnt/redis/data:/data"
~~~

3. elasticsearch
~~~yaml
elasticsearch:
    image: elasticsearch
    environment:
        ES_JAVA_OPTS: "-Xms128m -Xmx128m"
        discovery.type: "single-node"
        network.host: "0.0.0.0"
    ports:
        - "9200:9200"
        - "9300:9300"
    volumes:
        - "/mnt/elasticsearch/data:/usr/share/elasticsearch/data"
~~~

4. kafka
~~~yaml
zookeeper:
    image: wurstmeister/zookeeper
    ports:
        - "2181:2181"
kafka:
    image: wurstmeister/kafka
    ports:
        - "9092:9092"
    links:
        - "zookeeper:zookeeper"
    environment:
        KAFKA_ADVERTISED_HOST_NAME: 127.0.0.1
        KAFKA_CREATE_TOPICS: "test:1:1"
        KAFKA_ZOOKEEPER_CONNECT: "zookeeper:2181"
    volumes:
        - /var/run/docker.sock:/var/run/docker.sock
~~~