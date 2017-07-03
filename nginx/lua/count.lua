--
-- Created by IntelliJ IDEA.
-- User: limx
-- Date: 2017/7/1
-- Time: 下午6:11
-- To change this template use File | Settings | File Templates.
--
package.path = "/Users/limx/Applications/lua/nginx/?.lua;" .. package.path;

local config = require "config";
local key = ngx.var.http_user_agent;
local uri = ngx.var.arg__url;
local request_uri = ngx.var.request_uri;
--local uri = ngx.var.uri;

local redis = require('resty.redis');
local client = redis:new();
local time = 1000;
client:set_timeout(time); -- 1 sec
local ok, err = client:connect("127.0.0.1", 6379)
client:auth('910123');

local response = client:ping() -- true
-- print(response)
if response then
    if uri ~= nil then
        cot = client:hincrby('lua:phalcon:uri', uri, 1);
        client:hincrby('lua:phalcon:count', 'uri', 1);
    end
    client:hincrby('lua:phalcon:count', 'all', 1);
end





