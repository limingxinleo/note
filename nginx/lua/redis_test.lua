package.path = "/Users/limx/.luarocks/share/lua/5.2/?.lua;/usr/local/Cellar/openresty/1.11.2.3/lualib/?.lua;"..package.path;
package.cpath = "/Users/limx/.luarocks/lib/lua/5.2/?.so;/usr/local/Cellar/openresty/1.11.2.3/lualib/?.so;"..package.cpath;
-- ngx.say(package.path);
local redis = require('resty.redis');
local client = redis:new();
local time = 1000;
client:set_timeout(time); -- 1 sec
local ok, err = client:connect("127.0.0.1", 6379)
client:auth('910123');

local response = client:ping()           -- true
-- print(response)

cot = client:incr('lua:redis');
-- print(cot);

ngx.say(cot);