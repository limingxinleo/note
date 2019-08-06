# ETCD

etcd is a distributed reliable key-value store for the most critical data of a distributed system, with a focus on being:

- Simple: well-defined, user-facing API (gRPC)
- Secure: automatic TLS with optional client cert authentication
- Fast: benchmarked 10,000 writes/sec
- Reliable: properly distributed using Raft

## 安装

> gcr.io/etcd-development/etcd:v3.3.13 如果拉不下来，可以使用 limingxinleo/etcd:v3.3.13

```
# 内网地址
docker run \
  -p 2379:2379 \
  -p 2380:2380 \
  --restart=always \
  --volume=/mnt/etcd:/etcd-data \
  --name etcd -d \
  gcr.io/etcd-development/etcd:v3.3.13 /usr/local/bin/etcd \
  --data-dir=/etcd-data \
  --name node1 \
  --initial-advertise-peer-urls http://0.0.0.0:2380 \
  --listen-peer-urls http://0.0.0.0:2380 \
  --advertise-client-urls http://0.0.0.0:2379 \
  --listen-client-urls http://0.0.0.0:2379 \
  --initial-cluster node1=http://0.0.0.0:2380
```

## 安装 客户端

```
docker run --name etcdkeeper --restart always -d -p 12379:8080 deltaprojects/etcdkeeper
```