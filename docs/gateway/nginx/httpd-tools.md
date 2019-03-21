## Nginx 访问加密

### 安装
~~~
yum  -y install httpd-tools
~~~

### 设置第一个账号
~~~
htpasswd -c /mnt/nginx.passwd admin
chmod 777 /mnt/nginx.passwd
~~~

### 设置Nginx配置
~~~
#新增下面两行
auth_basic "Please input password"; #这里是验证时的提示信息 
auth_basic_user_file /mnt/nginx.passwd;
~~~

### 添加新账号
~~~
htpasswd -b /mnt/nginx.passwd limx 123456
~~~