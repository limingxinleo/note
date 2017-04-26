## MongoDB

### MongoDB 基本命令
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

### Mongo基本配置
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