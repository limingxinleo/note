# Kafka

## Docker 安装
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

## 使用
- 查看所有已经创建好的topic
~~~
kafka-topics.sh --list --zookeeper zookeeper:2181
~~~

- 生产命令
~~~
kafka-console-producer.sh --broker-list localhost:9092 --topic test
~~~

- 消费命令
~~~
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
~~~
