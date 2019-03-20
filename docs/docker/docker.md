# Docker

## 进入容器
~~~
docker exec -it name /bin/bash
~~~

## 映射
~~~
# --link选项的值的格式为：想要链接到的容器的名字:为想要链接到的容器取的内部别名。别名可以任意取，主要用于网络配置的解析。
--link db:db
# 宿主机端口:容器内部端口
-p 9200:9200
~~~

## RabbitMQ
~~~
docker run -d --restart=always --name rabbitmq -p 4369:4369 -p 5672:5672 -p 15672:15672 -p 25672:25672 -v /opt/lib/rabbitmq:/var/lib/rabbitmq rabbitmq:management-alpine
~~~

## ElasticSearch
~~~
docker run --rm -d --name elasticsearch -p 9200:9200 -p 9300:9300 \
-v /mnt/elasticsearch/data:/usr/share/elasticsearch/data -e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
-e "discovery.type=single-node" elasticsearch:5-alpine
~~~

## 给用户权限
给user用户docker权限
~~~
sudo usermod -aG docker user
~~~

## gitlab-runner发布时显示无权限
~~~
su gitlab-runner
docker login ...
~~~

## Docker 定时清理容器
~~~
docker system prune -a -f --volumes
~~~

## 查看内网地址
~~~
docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONTAINER_ID
~~~

## Linux 安装
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

# jenkins
docker pull jenkins
chown -R 1000:1000 /mnt/jenkins/
docker run --restart unless-stopped -p 8080:8080 -p 50000:50000 --name jenkins -v /mnt/jenkins:/var/jenkins_home -d jenkins

# jenkins php
$ docker pull limingxinleo/jenkins-php-docker
$ useradd jenkins
$ chown -R jenkins:jenkins /mnt/jenkins/
$ docker run --restart unless-stopped -p 8080:8080 -p 50000:50000 --name jenkins \
-e "PATH=/home/jenkins/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
-v "/mnt/jenkins:/var/jenkins_home" -d limingxinleo/jenkins-php-docker
~~~


## docker-compose

### 报错解决
1. Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?
~~~
$ sudo docker-compose up -d

ERROR: Couldn't connect to Docker daemon at http+docker://localunixsocket - is it running?

If it's at a non-standard location, specify the URL with the DOCKER_HOST environment variable.

# 解决：设置DOCKER_HOST，我的docker跑在sock上，所以按照如下设置
export DOCKER_HOST=/var/run/docker.sock
~~~

### 配置docker-compose.yml
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

5. jenkins
~~~yaml
jenkins:
    image: jenkins
    restart: unless-stopped
    ports:
        - "8080:8080"
        - "50000:50000"
    volumes:
        - /Users/limx/runtime/jenkins:/var/jenkins_home
~~~

## Dockerfiles

- [php-fpm](https://github.com/limingxinleo/note/blob/master/docs/docker/Dockerfiles/fpm.Dockerfile)
- [grpc](https://github.com/limingxinleo/note/blob/master/docs/docker/Dockerfiles/grpc.Dockerfile)
- [swoft](https://github.com/limingxinleo/note/blob/master/docs/docker/Dockerfiles/swoft.Dockerfile)
- [h5](https://github.com/limingxinleo/note/blob/master/docs/docker/Dockerfiles/web.Dockerfile)