--
-- Author: shineflag
-- Date: 2017-02-14 17:18:53
--
local clienttype
if device.platform == "android" then
    clienttype = 1
elseif device.platform == "ios" then
    clienttype = 2
elseif device.platform == "windows" then
    clienttype = 3
else
    clienttype = 0
end


local config = {
	sid = 100,-- 帐号类型 100：游客
    os = clienttype,-- Android:1 iOS:2 
    bid = 0,-- "4";  --发行渠道 4大厅 5华为 6收录包 7为新联
    mtkey = "",
    versions = "1.0.0",
    clienttype = clienttype,-- 系统类型1 android 2 android pad 3.ios 4.ios pad
    clientid = 100,-- 100;   --包ID,在数据库中配置android主线包100,102为联想,103为华为,104为联通
    lang = "zh_HK",
}


return config