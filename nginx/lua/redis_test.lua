package.path = "/Users/limx/.luarocks/share/lua/5.2/?.lua;"..package.path;
package.cpath = "/Users/limx/.luarocks/lib/lua/5.2/?.so;"..package.cpath;
local redis = require 'redis';
local client = redis.connect('127.0.0.1', 6379);
client:auth('910123');
local response = client:ping()           -- true
print(response)

cot = client:incr('lua:redis');
print(cot);