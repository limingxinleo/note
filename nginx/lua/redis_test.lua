package.path = "./?.lua;"..package.path;
config = require("config");
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