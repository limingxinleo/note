## Elasticsearch

### 坑
(http://www.mamicode.com/info-detail-1775575.html)[elasticsearch安装之各种坑]

### 安装
1. 安装java环境 （jre 或者 openjdk）
2. 解压缩要安装到/opt/elasticsearch/下

### 修改内存
Java HotSpot(TM) 64-Bit Server VM warning: INFO: os::commit_memory(0x0000000085330000, 2060255232, 0) failed; error=‘Cannot allocate memory‘ (errno=12)
~~~
vim config/jvm.options
#-Xms2g
#-Xmx2g
-Xms128m
-Xmx128m
~~~

### 添加新用户
~~~
groupadd elsearch
#useradd elsearch -g elsearch -p elasticsearch
useradd elsearch -g elsearch
~~~

### 启动
~~~
./bin/elasticsearch -d
~~~

### 测试
~~~
curl http://localhost:9200/
~~~