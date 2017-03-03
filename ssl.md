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

