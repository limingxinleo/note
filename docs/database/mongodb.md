# MongoDB

## MongoDB 基本命令
1.进入mongodb数据库
~~~
$ mongo
~~~

2.基本操作
~~~
show dbs                    显示数据库列表 
show collections            显示当前数据库中的集合（类似关系数据库中的表） 
show users                  显示用户

use <db name>               切换当前数据库，这和MS-SQL里面的意思一样 
db.help()                   显示数据库操作命令，里面有很多的命令 
db.foo.help()               显示集合操作命令，同样有很多的命令，foo指的是当前数据库下，一个叫foo的集合，并非真正意义上的命令 
db.foo.find()               对于当前数据库中的foo集合进行数据查找（由于没有条件，会列出所有数据） 
db.foo.find( { a : 1 } )    对于当前数据库中的foo集合进行查找，条件是数据中有一个属性叫a，且a的值为1
~~~

3.添加管理员
添加管理员
~~~
use admin
db.createUser({user:"admin",pwd:"password",roles:["root"]})
~~~
添加管理员后需要认证后才能继续操作
~~~
db.auth("admin","password")
~~~

## Mongo基本配置
vim /usr/local/etc/mongod.conf
~~~
systemLog:
  destination: file
  path: /usr/local/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /usr/local/var/mongodb
net:
  bindIp: 127.0.0.1
~~~
运行命令
~~~
mongod --config /usr/local/etc/mongod.conf --auth &
~~~

## 索引
查看索引
~~~
db.table.getIndexex()
~~~
创建索引
~~~
# 数字1表示username键的索引按升序存储，-1表示age键的索引按照降序方式存储。
db.table.createIndex({"username":1})
db.table.createIndex({"username":1, "age":-1})
# 唯一索引
db.table.createIndex({"userid":1},{"unique":true})
~~~
删除索引
~~~
db.table.dropIndex({"username":1})
~~~
设置超时时间
~~~
db.table.createIndex({"timerd":1}, {expireAfterSeconds: 10})
~~~

## 参数说明

基本配置
~~~
--quiet	                        # 安静输出
--port arg	                    # 指定服务端口号，默认端口27017
--bind_ip arg	                # 绑定服务IP，若绑定127.0.0.1，则只能本机访问，不指定默认本地所有IP
--logpath arg	                # 指定MongoDB日志文件，注意是指定文件不是目录
--logappend	                    # 使用追加的方式写日志
--pidfilepath arg	            # PID File 的完整路径，如果没有设置，则没有PID文件
--keyFile arg	                # 集群的私钥的完整路径，只对于Replica Set 架构有效
--unixSocketPrefix arg	        # UNIX域套接字替代目录,(默认为 /tmp)
--fork	                        # 以守护进程的方式运行MongoDB，创建服务器进程
--auth	                        # 启用验证
--cpu	                        # 定期显示CPU的CPU利用率和iowait
--dbpath arg	                # 指定数据库路径
--diaglog arg	                # diaglog选项 0=off 1=W 2=R 3=both 7=W+some reads
--directoryperdb	            # 设置每个数据库将被保存在一个单独的目录
--journal	                    # 启用日志选项，MongoDB的数据操作将会写入到journal文件夹的文件里
--journalOptions arg	        # 启用日志诊断选项
--ipv6	                        # 启用IPv6选项
--jsonp	                        # 允许JSONP形式通过HTTP访问（有安全影响）
--maxConns arg	                # 最大同时连接数 默认2000
--noauth	                    # 不启用验证
--nohttpinterface	            # 关闭http接口，默认关闭27018端口访问
--noprealloc	                # 禁用数据文件预分配(往往影响性能)
--noscripting	                # 禁用脚本引擎
--notablescan	                # 不允许表扫描
--nounixsocket	                # 禁用Unix套接字监听
--nssize arg (=16)	            # 设置信数据库.ns文件大小(MB)
--objcheck	                    # 在收到客户数据,检查的有效性，
--profile arg	                # 档案参数 0=off 1=slow, 2=all
--quota	                        # 限制每个数据库的文件数，设置默认为8
--quotaFiles arg	            # number of files allower per db, requires --quota
--rest	                        # 开启简单的rest API
--repair	                    # 修复所有数据库run repair on all dbs
--repairpath arg	            # 修复库生成的文件的目录,默认为目录名称dbpath
--slowms arg (=100)	            # value of slow for profile and console log
--smallfiles	                # 使用较小的默认文件
--syncdelay arg (=60)	        # 数据写入磁盘的时间秒数(0=never,不推荐)
--sysinfo	                    # 打印一些诊断系统信息
--upgrade	                    # 如果需要升级数据库  * Replicaton 参数

--------------------------------------------------------------------------------

--fastsync	                    # 从一个dbpath里启用从库复制服务，该dbpath的数据库是主库的快照，可用于快速启用同步
--autoresync	                # 如果从库与主库同步数据差得多，自动重新同步，
--oplogSize arg	                # 设置oplog的大小(MB)  * 主/从参数

--------------------------------------------------------------------------------

--master	                    # 主库模式
--slave	                        # 从库模式
--source arg	                # 从库 端口号
--only arg	                    # 指定单一的数据库复制
--slavedelay arg	            # 设置从库同步主库的延迟时间  * Replica set(副本集)选项：

--------------------------------------------------------------------------------

--replSet arg	                # 设置副本集名称  * Sharding(分片)选项

--------------------------------------------------------------------------------
--configsvr	                    # 声明这是一个集群的config服务,默认端口27019，默认目录/data/configdb
--shardsvr	                    # 声明这是一个集群的分片,默认端口27018
--noMoveParanoia	            # 关闭偏执为moveChunk数据保存
~~~
上述参数都可以写入 mongod.conf 配置文档里例如：
(https://docs.mongodb.com/manual/reference/configuration-options/#configuration-file)[https://docs.mongodb.com/manual/reference/configuration-options/#configuration-file]
~~~
systemLog:
  destination: file
  path: /usr/local/var/log/mongodb/mongo.log
  logAppend: true
storage:
  dbPath: /usr/local/var/mongodb
net:
  bindIp: 127.0.0.1
processManagement:
  fork: true
~~~
