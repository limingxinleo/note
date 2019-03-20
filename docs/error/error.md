## configure:error
* You need a C++ compiler for C++ support
~~~
yum install -y gcc gcc-c++
~~~

## 小程序蓝牙通信
* IOS无法获取设备MAC地址
* IOS的服务UUID和特征值UUID必须大写
* Android的服务UUID和特征值UUID必须小写
* IOS读取数据前，必须经过扫描设备，查询服务ID，查询特征值ID之后，才能获取到
* IOS读取到的adviseData是经过base64的buffer，所以需要先从base64转化为buffer，然后再转化为16进制数

