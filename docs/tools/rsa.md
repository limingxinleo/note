## RSA加密
* 生成RSA私钥
~~~
openssl genrsa -out rsa_private_key.pem 1024
~~~

* 把RSA私钥转换成PKCS8格式
~~~
openssl pkcs8 -topk8 -inform PEM -in rsa_private_key.pem -outform PEM –nocrypt
~~~

* 生成公钥
~~~
openssl rsa -in rsa_private_key.pem -out rsa_public_key.pem -pubout 
~~~