## BIND Linux DNS 解析服务

### 安装
~~~
yum install bind
~~~

### 启动
~~~
service named start
~~~

### 配置
~~~
# 修改 /etc/named.conf 增加新的zone
include "/etc/named.coding.zones";

# 新建 /etc/named.coding.zones 文件, 内容如下
zone "coding.xin" IN {
        type master;
        file "named.coding.xin";
        allow-update { none; };
};

# 新建 /var/named/named.coding.xin 文件，内容如下
$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial # 每次修改dns解析，这里+1
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
        A       127.0.0.1
        AAAA    ::1
test    IN      A       127.0.0.1 # 新增子域名DNS解析

# 检查配置
/usr/sbin/named-checkconf -z

# 赋予权限
chown root:named /etc/named.coding.zones
chown root:named /var/named/named.coding.xin

# 重启服务
service named reload

# 客户端配置DNS
vim /etc/resolv.conf
增加以下代码
nameserver your_dns_ip
~~~