## SSL

### 申请免费的ssl证书
[https://www.startssl.com](https://www.startssl.com)

* 生成自己的scr和key
~~~
openssl req -newkey rsa:2048 -keyout yourname.key -out yourname.csr
~~~
* 利用scr换取网站上的bundle.scr
* 上传bundle.scr 和 yourname.key 到服务器

### 不使用免费的SSL证书 自己生成证书
[参考文章](http://www.tuicool.com/articles/BbmENr)
* 为服务器端和客户端准备公钥、私钥
~~~
# 生成服务器端私钥
openssl genrsa -out server.key 1024
# 生成服务器端公钥
openssl rsa -in server.key -pubout -out server.pem


# 生成客户端私钥
openssl genrsa -out client.key 1024
# 生成客户端公钥
openssl rsa -in client.key -pubout -out client.pem
~~~

* 生成 CA 证书
~~~
# 生成 CA 私钥
openssl genrsa -out ca.key 1024
# X.509 Certificate Signing Request (CSR) Management.
openssl req -new -key ca.key -out ca.csr
# X.509 Certificate Data Management.
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt
~~~

> 第二步会出现以下情况

~~~
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:ShangHai
Locality Name (eg, city) []:ShangHai
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Limx
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:yourwebsite.com
Email Address []:
~~~

> 注意，这里的 Organization Name (eg, company) [Internet Widgits Pty Ltd]: 后面生成客户端和服务器端证书的时候也需要填写，不要写成一样的！！！可以随意写如：My CA, My Server, My Client。
  
> 然后 Common Name (e.g. server FQDN or YOUR name) []: 这一项，是最后可以访问的域名，如果是为了给网站生成证书，需要写成 yourwebsite.com 。

> 再就是密码，不需要输入密码。输入密码的话，后面启动Nginx也需要输入密码。

* 生成服务器端证书和客户端证书
~~~
# 服务器端需要向 CA 机构申请签名证书，在申请签名证书之前依然是创建自己的 CSR 文件
openssl req -new -key server.key -out server.csr
# 向自己的 CA 机构申请证书，签名过程需要 CA 的证书和私钥参与，最终颁发一个带有 CA 签名的证书
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in server.csr -out server.crt

# client 端
openssl req -new -key client.key -out client.csr
# client 端到 CA 签名
openssl x509 -req -CA ca.crt -CAkey ca.key -CAcreateserial -in client.csr -out client.crt
~~~

* 结构如下
~~~
├── ca.crt
├── ca.csr
├── ca.key
├── ca.srl
├── client.crt
├── client.csr
├── client.key
├── client.pem
├── server.crt
├── server.csr
├── server.key
└── server.pem
~~~

> 配置server.key 和 server.crt 到服务端。客户端访问https协议时，携带自己的client.key 和 client.crt即可。

### 配置Nginx
* 增加ssl的配置文件

> 修改下面四处[]以及rewrite规则

~~~
server {
    server_name [demo.cn];
    listen 443;
    ssl on;
    ssl_certificate [bundle.scr];
    ssl_certificate_key [yourname.key];
    # 若ssl_certificate_key使用33iq.key，则每次启动Nginx服务器都要求输入key的密码。
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers "EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !MEDIUM";

    root   [/your/path/to/demo];
    index  index.html index.htm index.php;

    client_max_body_size 8M;

    #charset koi8-r;
    #access_log  /var/log/nginx/log/host.access.log  main;

    location / {
        if (!-e $request_filename) {
            rewrite "^/(.*)$" /index.php?_url=/$1 last;
        }
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    location ~ \.php(.*)$  {
        fastcgi_pass   127.0.0.1:9000;
        fastcgi_index  index.php;
        fastcgi_split_path_info  ^((?U).+\.php)(/?.+)$;
        if ($fastcgi_script_name ~ "^(.+?\.php)(/.+)$") {
            set $real_script_name $1;
            set $path_info $2;
        }
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param  PATH_INFO  $fastcgi_path_info;
        fastcgi_param  PATH_TRANSLATED  $document_root$fastcgi_path_info;
        include        fastcgi_params;
    }
}
~~~

### 重启服务器即可

> PS:谷歌已经不信任StartCom的CA证书。

