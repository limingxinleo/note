# JAVA

## 启动java，并打印pid
~~~
java -jar xxx-1.0.0-SNAPSHOT.jar -server -Xms2048m -Xmx2048m -Xmn400m -Xss256k -XX:PermSize=256m -XX:MaxPermSize=512m --spring.profiles.active=qa & echo $! > xxx.pid
~~~