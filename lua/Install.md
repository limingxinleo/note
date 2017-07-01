## 安装
MAC
~~~
brew install lua
luarocks install redis-lua --local
~~~

Linux
~~~

~~~

## 使用
找不到扩展
~~~
利用luarocks把扩展都装到一起，然后在使用的时候重写package路径，或者直接写到LUA_PATH LUA_CPATH
package.path = "/Users/limx/.luarocks/share/lua/5.2/?.lua;"..package.path;
package.cpath = "/Users/limx/.luarocks/lib/lua/5.2/?.so;"..package.cpath;
~~~