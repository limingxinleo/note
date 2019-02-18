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